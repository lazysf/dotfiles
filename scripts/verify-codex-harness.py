#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DOT_CODEX = ROOT / "dot_codex"
AGENTS_DIR = DOT_CODEX / "agents"
RULES_DIR = DOT_CODEX / "rules"
DOCS_DIR = DOT_CODEX / "docs"

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
ROOT_ADR_RE = re.compile(r"(^|[(/`\s])docs/adr/|^\.\.?/docs/adr/", re.MULTILINE)
PROJECT_DOT_CODEX_RE = re.compile(r"(^|[`\s(])\./\.codex/?")
FORBIDDEN_DOT_CODEX_DOC_NAMES = {
    "harness-engineering-best-practices.md",
    "harness-regression-scenarios.md",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def check_agents() -> None:
    for path in sorted(AGENTS_DIR.glob("*.toml")):
        data = tomllib.loads(path.read_text())
        missing = sorted(REQUIRED_AGENT_KEYS - set(data.keys()))
        if missing:
            fail(f"{path.relative_to(ROOT)} is missing keys: {', '.join(missing)}")


def check_rules() -> None:
    for path in sorted(RULES_DIR.glob("*.rules")):
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


def check_markdown() -> None:
    for path in sorted(DOT_CODEX.rglob("*.md")):
        text = path.read_text()
        if ROOT_ADR_RE.search(text):
            fail(f"{path.relative_to(ROOT)} must not reference root docs/adr")
        if PROJECT_DOT_CODEX_RE.search(text):
            fail(f"{path.relative_to(ROOT)} must not recommend ./.codex as knowledge storage")
        for match in MARKDOWN_LINK_RE.finditer(text):
            resolve_markdown_link(path, match.group(1))
    for path in sorted(DOT_CODEX.rglob("*.md")):
        if path.name in FORBIDDEN_DOT_CODEX_DOC_NAMES:
            fail(f"{path.relative_to(ROOT)} must remain a root-level knowledge doc")


def check_docs_index() -> None:
    readme_path = DOCS_DIR / "README.md"
    readme_text = readme_path.read_text()
    linked_docs = set()
    for match in MARKDOWN_LINK_RE.finditer(readme_text):
        target = match.group(1).split("#", 1)[0]
        if not target.endswith(".md"):
            continue
        resolved = (readme_path.parent / target).resolve()
        if resolved.parent == DOCS_DIR and resolved != readme_path:
            linked_docs.add(resolved.name)

    doc_files = {path.name for path in DOCS_DIR.glob("*.md") if path.name != "README.md"}
    missing = sorted(doc_files - linked_docs)
    if missing:
        fail(f"dot_codex/docs/README.md is missing links to: {', '.join(missing)}")


def main() -> None:
    check_agents()
    check_rules()
    check_markdown()
    check_docs_index()
    print("Codex harness verification passed.")


if __name__ == "__main__":
    main()
