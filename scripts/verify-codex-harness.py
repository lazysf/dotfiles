#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DOT_CODEX = ROOT / "dot_codex"
DOCS = ROOT / "docs"

REQUIRED_AGENT_KEYS = {
    "name",
    "description",
    "model",
    "model_reasoning_effort",
    "sandbox_mode",
    "developer_instructions",
}

MARKDOWN_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
RULE_DECISION_RE = re.compile(r'decision\s*=\s*"(allow|prompt|forbidden)"')
RULE_PATTERN_RE = re.compile(r"prefix_rule\s*\(")
PROJECT_DOT_CODEX_RE = re.compile(r"(^|[`\s(])\./\.codex/?")

GIT_COMMIT_SKILL_EXPECTED = (
    "この skill では、手順に明示した Git コマンドだけを使う。",
    "`git status -sb`",
    "`git diff`",
    "`git diff --staged`",
    "`git add <paths>`",
    '`git commit -m "<header>"`',
    "`git commit -F <file>`",
    "成功した commit では、最低限 `branch`、`commit`、`message`、`knowledge_capture` を含める。",
)

GIT_PUSH_SKILL_EXPECTED = (
    "この skill では、手順に明示した Git コマンドだけを使う。",
    "通常 push は引き続き approval / `prompt` 前提で扱う。",
    "`git status -sb`",
    "`git branch -vv`",
    "`git remote -v`",
    "`git push`",
    "`git push -u <remote> <branch>`",
    "`git push <remote> <branch>`",
    "`git-push` の結果報告では常に、最低限 `remote`、`branch`、`upstream`、`action`、`result` を含める。",
    "`action` は `git push`、`git push -u <remote> <branch>`、`git push <remote> <branch>` のどれを実行したか、または no-op / 事前停止で判定した push 操作を返す。",
    "`result` は最低でも `pushed` / `nothing-to-push` / `skipped` / `failed` を表現できるようにする。",
    "`upstream` は既存 upstream を使ったのか、今回設定したのか、未設定のまま push しなかったのかが分かる user-facing な短い値で返す。",
    "`notes` と `next_action` は任意にし、ADR 状態更新の補足、behind / diverged、認証失敗などの追加説明が必要な場合だけ使う。",
)

GIT_RULE_EXPECTED = {
    DOT_CODEX / "rules" / "git-add.rules": (
        'pattern = ["git", "add"]',
        "`git-commit` skill",
        '"git add README.md"',
        '"git add dir/file1 dir/file2"',
        '"git add ."',
        '"git add -A"',
        '"git add --patch"',
    ),
    DOT_CODEX / "rules" / "git-push.rules": (
        'pattern = ["git", "push"]',
        "`git-push` skill",
        '"git push --force"',
    ),
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def check_agents() -> None:
    for path in sorted((DOT_CODEX / "agents").glob("*.toml")):
        data = tomllib.loads(path.read_text())
        missing = sorted(REQUIRED_AGENT_KEYS - set(data.keys()))
        if missing:
            fail(f"{path.relative_to(ROOT)} is missing keys: {', '.join(missing)}")


def check_rules() -> None:
    for path in sorted((DOT_CODEX / "rules").glob("*.rules")):
        text = path.read_text()
        if not RULE_PATTERN_RE.search(text):
            fail(f"{path.relative_to(ROOT)} does not contain prefix_rule(...)")
        if not RULE_DECISION_RE.search(text):
            fail(f"{path.relative_to(ROOT)} does not declare decision")
        if "justification" not in text:
            fail(f"{path.relative_to(ROOT)} does not declare justification")


def resolve_markdown_link(source: Path, target: str) -> None:
    if target.startswith(("http://", "https://", "mailto:", "#", "/")):
        return
    if ":" in target and not target.startswith("../") and not target.startswith("./"):
        return
    clean = target.split("#", 1)[0]
    if not clean:
        return
    resolved = (source.parent / clean).resolve()
    if not resolved.exists():
        fail(f"{source.relative_to(ROOT)} references missing path: {target}")


def check_markdown_links() -> None:
    for root in (DOT_CODEX, DOCS):
        for path in sorted(root.rglob("*.md")):
            text = path.read_text()
            if PROJECT_DOT_CODEX_RE.search(text):
                fail(f"{path.relative_to(ROOT)} must not recommend ./.codex as knowledge storage")
            for match in MARKDOWN_LINK_RE.finditer(text):
                resolve_markdown_link(path, match.group(1))


def check_git_command_surface() -> None:
    git_commit = (DOT_CODEX / "skills" / "git-commit" / "SKILL.md").read_text()
    for token in GIT_COMMIT_SKILL_EXPECTED:
        if token not in git_commit:
            fail(f"dot_codex/skills/git-commit/SKILL.md is missing: {token}")

    git_push = (DOT_CODEX / "skills" / "git-push" / "SKILL.md").read_text()
    for token in GIT_PUSH_SKILL_EXPECTED:
        if token not in git_push:
            fail(f"dot_codex/skills/git-push/SKILL.md is missing: {token}")

    for path, tokens in GIT_RULE_EXPECTED.items():
        text = path.read_text()
        for token in tokens:
            if token not in text:
                fail(f"{path.relative_to(ROOT)} is missing: {token}")


def main() -> None:
    check_agents()
    check_rules()
    check_markdown_links()
    check_git_command_surface()
    print("Codex harness verification passed.")


if __name__ == "__main__":
    main()
