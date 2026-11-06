"""Merge the macOS personal signing settings using Codex's config API."""

import json
from fnmatch import fnmatchcase
import os
from pathlib import Path
import re
import select
import shutil
import subprocess
import sys
import tempfile
import time

PROFILE = "agent-signing"
PROFILE_KEY = f"permissions.{PROFILE}"
ZSH_STARTUP = ("~/.zshenv", "~/.zprofile", "~/.zlogin", "~/.config/zsh")
HOOK = {
    "type": "command",
    "command": '"$HOME/.config/git/start-signing-agent" >/dev/null',
    "timeout": 15,
}
MISSING = object()


class ConfigError(Exception):
    pass


class CodexConfig:
    def __init__(self, process):
        self.process = process
        self.buffer = bytearray()
        self.request_id = 0

    def send(self, method, params=None, *, request=True):
        message = {"method": method}
        if params is not None:
            message["params"] = params
        if request:
            self.request_id += 1
            message["id"] = self.request_id
        self.process.stdin.write(json.dumps(message).encode() + b"\n")
        self.process.stdin.flush()
        if not request:
            return None

        deadline = time.monotonic() + 15
        while True:
            line, separator, rest = self.buffer.partition(b"\n")
            if separator:
                self.buffer = rest
                reply = json.loads(line)
                if reply.get("id") != self.request_id:
                    continue
                if "error" in reply:
                    raise ConfigError(f"{method} failed (RPC {reply['error'].get('code')})")
                return reply["result"]
            remaining = deadline - time.monotonic()
            if remaining <= 0 or not select.select([self.process.stdout], [], [], remaining)[0]:
                raise ConfigError(f"{method} timed out")
            chunk = os.read(self.process.stdout.fileno(), 65536)
            if not chunk:
                raise ConfigError(f"{method}: Codex app-server exited")
            self.buffer.extend(chunk)


def regular_contents(path):
    if path.is_symlink() or (path.exists() and not path.is_file()):
        raise ConfigError(f"{path.name} must be a regular file")
    return path.read_bytes() if path.exists() else None


def hook_update(original):
    document = json.loads(original) if original is not None else {}
    groups = document.setdefault("hooks", {}).setdefault("SessionStart", [])
    matches = [
        (group, handler)
        for group in groups
        for handler in group["hooks"]
        if "start-signing-agent" in handler.get("command", "")
    ]
    if matches:
        if (
            len(matches) == 1
            and matches[0][0].get("matcher") in (None, "")
            and matches[0][1] == HOOK
        ):
            return None
        raise ConfigError("existing SessionStart signing hook conflicts")
    groups.append({"hooks": [HOOK]})
    return (json.dumps(document, indent=2, ensure_ascii=False) + "\n").encode()


def replace_hook(path, previous, content):
    if regular_contents(path) != previous:
        raise ConfigError("hooks.json changed during setup; retry chezmoi apply")
    if content is None:
        path.unlink()
        return
    mode = path.stat().st_mode & 0o777 if previous is not None else 0o600
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as temporary:
        staged = Path(temporary.name)
    try:
        staged.chmod(mode)
        staged.write_bytes(content)
        if regular_contents(path) != previous:
            raise ConfigError("hooks.json changed during setup; retry chezmoi apply")
        if previous is None:
            os.link(staged, path)  # Fail if another process created the file.
        else:
            staged.replace(path)
    finally:
        staged.unlink(missing_ok=True)


def setting(config, key_path):
    for part in key_path.split("."):
        if not isinstance(config, dict):
            raise ConfigError(f"invalid existing settings for {key_path}")
        if part not in config:
            return MISSING
        config = config[part]
    return config


def config_edits(layers, user_layer, wanted, legacy_profile):
    for layer in layers:
        if layer["name"]["type"] == "packagedDefaults":
            continue
        config = layer["config"]
        if setting(config, "features.hooks") is False:
            raise ConfigError("existing features.hooks disables the signing hook")
        for key in ("sandbox_mode", "sandbox_workspace_write"):
            if key in config:
                raise ConfigError(f"existing {key} conflicts with the signing profile")
        inline = config.get("hooks", {}).get("SessionStart", [])
        if any("start-signing-agent" in h.get("command", "") for g in inline for h in g["hooks"]):
            raise ConfigError("existing inline SessionStart signing hook conflicts")
        policy = config.get("shell_environment_policy", {})
        env = policy.get("set", {})
        includes = policy.get("include_only") or [
            pattern for pattern, action in policy.get("filters", {}).items() if action == "include"
        ]
        if includes and any(
            not any(fnmatchcase(key.lower(), pattern.lower()) for pattern in includes)
            for key in (name.rsplit(".", 1)[-1] for name in wanted if name.startswith("shell_environment_policy.set."))
        ):
            raise ConfigError("existing shell environment allowlist excludes signing variables")
        for key in env:
            if key.startswith("GIT_CONFIG_") and f"shell_environment_policy.set.{key}" not in wanted:
                raise ConfigError("existing GIT_CONFIG_* settings conflict with signing")
        for key, desired in wanted.items():
            value = setting(config, key)
            if layer is user_layer and key == PROFILE_KEY and value == legacy_profile:
                continue
            if value is not MISSING and (type(value) is not type(desired) or value != desired):
                raise ConfigError(f"existing {key} conflicts with signing")
    return [
        {"keyPath": key, "value": value, "mergeStrategy": "upsert"}
        for key, value in wanted.items()
        if setting(user_layer["config"], key) != value
    ]


def configure(home):
    key = home / ".ssh/agent_signing_ed25519.pub"
    if not key.is_file():
        print("Codex signing: public key not available; will retry on the next chezmoi apply")
        return
    if not key.with_suffix("").is_file():
        raise ConfigError("the signing key pair is incomplete")
    with key.open(newline="") as public:
        fields = public.readline().rstrip("\n").split(" ")[:2]
    if len(fields) != 2 or fields[0] != "ssh-ed25519" or not re.fullmatch(r"[A-Za-z0-9+/]+=*", fields[1]):
        raise ConfigError("invalid signing public key")
    if not os.access(home / ".config/git/start-signing-agent", os.X_OK):
        raise ConfigError("shared signing helper is not installed")
    bundled = Path("/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex")
    codex = str(bundled) if os.access(bundled, os.X_OK) else shutil.which("codex")
    if not codex:
        raise ConfigError("Codex CLI is not installed")

    codex_home = home / ".codex"
    if codex_home.is_symlink():
        raise ConfigError(".codex must be a local directory")
    config, hooks = codex_home / "config.toml", codex_home / "hooks.json"
    original_config = regular_contents(config)
    original_hooks = regular_contents(hooks)
    updated_hooks = hook_update(original_hooks)
    socket = str(home / ".local/state/agent-signing/agent.sock")
    env = {
        "SSH_AUTH_SOCK": socket,
        "GIT_CONFIG_COUNT": "2",
        "GIT_CONFIG_KEY_0": "gpg.ssh.program",
        "GIT_CONFIG_VALUE_0": "/usr/bin/ssh-keygen",
        "GIT_CONFIG_KEY_1": "user.signingkey",
        "GIT_CONFIG_VALUE_1": "key::" + " ".join(fields),
    }
    legacy_profile = {
        "extends": ":workspace",
        "filesystem": {
            "~/.ssh": "deny",
            "~/.local/state/agent-signing": "read",
            "~/.config/git/start-signing-agent": "read",
            "~/.claude/hooks/signing-agent.sh": "read",
            "~/.codex/hooks.json": "read",
            "~/.codex/config.toml": "read",
        },
        "network": {"enabled": True, "unix_sockets": {socket: "allow"}},
    }
    # Codex command hooks use a login shell before executing the helper.
    profile = {
        **legacy_profile,
        "filesystem": {
            **legacy_profile["filesystem"],
            **dict.fromkeys(ZSH_STARTUP, "read"),
        },
    }
    wanted = {
        "default_permissions": PROFILE,
        "features.network_proxy": True,
        PROFILE_KEY: profile,
        **{f"shell_environment_policy.set.{key}": value for key, value in env.items()},
    }

    # The app-server requires CODEX_HOME to exist even on first install.
    codex_home.mkdir(mode=0o700, exist_ok=True)
    with subprocess.Popen(
        [codex, "app-server", "--listen", "stdio://"], cwd=home,
        env=dict(os.environ, HOME=str(home), CODEX_HOME=str(codex_home)),
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
    ) as process:
        try:
            rpc = CodexConfig(process)
            rpc.send("initialize", {"clientInfo": {"name": "chezmoi-signing", "version": "1"}})
            rpc.send("initialized", request=False)
            layers = rpc.send("config/read", {"includeLayers": True})["layers"]
            user_layer = next(layer for layer in layers if layer["name"]["type"] == "user")
            edits = config_edits(layers, user_layer, wanted, legacy_profile)
            if edits:
                features = rpc.send("experimentalFeature/list", {"limit": 1000})["data"]
                if not any(feature["name"] == "network_proxy" for feature in features):
                    raise ConfigError("Codex does not support the required network proxy")
                requirements = rpc.send("configRequirements/read")["requirements"]
                if requirements is not None:
                    raise ConfigError("managed Codex requirements are present; signing setup skipped")
            if regular_contents(config) != original_config or regular_contents(hooks) != original_hooks:
                raise ConfigError("Codex settings changed during setup; retry chezmoi apply")
            if updated_hooks is not None:
                replace_hook(hooks, original_hooks, updated_hooks)
            try:
                if edits:
                    rpc.send("config/batchWrite", {"edits": edits, "expectedVersion": user_layer["version"]})
            except Exception as error:
                # A timeout can occur after the write. Stop the writer before
                # deciding whether removing the new hook would break signing.
                process.terminate()
                process.wait(timeout=5)
                if updated_hooks is not None:
                    if regular_contents(config) != original_config:
                        raise ConfigError(
                            "config.toml changed after a write error; hook kept, retry chezmoi apply"
                        ) from error
                    replace_hook(hooks, updated_hooks, original_hooks)
                raise
        finally:
            process.terminate()

    if updated_hooks is not None:
        print("Codex signing: review the SessionStart hook in /hooks")
    else:
        print("Codex signing: hook already configured")


if __name__ == "__main__":
    try:
        configure(Path(sys.argv[1]))
    except (ConfigError, OSError, ValueError, KeyError, TypeError, AttributeError, StopIteration,
            subprocess.TimeoutExpired) as error:
        # Parse and filesystem errors can contain machine paths or config contents.
        message = str(error) if isinstance(error, ConfigError) else type(error).__name__
        sys.exit(f"Codex signing: {message}")
