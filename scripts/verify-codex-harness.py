#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DOT_CODEX = ROOT / "dot_codex"
DOCS = ROOT / "docs"
DOCS_README = DOCS / "README.md"
KNOWLEDGE_DIR = DOCS / "knowledge"

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
EXPECTED_KNOWLEDGE_DOCS = {
    "classification-driven-workflow-surface.md",
    "harness-design-principles.md",
    "harness-regression-checks.md",
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


def check_docs_readme() -> None:
    readme_text = DOCS_README.read_text()
    linked_docs = set()
    for match in MARKDOWN_LINK_RE.finditer(readme_text):
        target = match.group(1).split("#", 1)[0]
        if not target.endswith(".md"):
            continue
        resolved = (DOCS_README.parent / target).resolve()
        if resolved.parent == KNOWLEDGE_DIR:
            linked_docs.add(resolved.name)
    missing = sorted(EXPECTED_KNOWLEDGE_DOCS - linked_docs)
    if missing:
        fail(f"docs/README.md is missing links to: {', '.join(missing)}")


def main() -> None:
    check_agents()
    check_rules()
    check_markdown_links()
    check_docs_readme()
    print("Codex harness verification passed.")


if __name__ == "__main__":
    main()
