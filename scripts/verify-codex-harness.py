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
ADR_DIR = DOCS / "adr"

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
LEGACY_SKILL_DIR_PREFIXES = ("core-", "phase-")
LEGACY_SKILL_NAME_RE = re.compile(r"^name:\s*(core-|phase-|entry-)", re.MULTILINE)
REVIEW_FULL_ENTRY_PATHS = (
    DOT_CODEX / "AGENTS.md",
    DOCS / "knowledge" / "classification-driven-workflow-surface.md",
    DOCS / "knowledge" / "harness-regression-checks.md",
)
REVIEW_INDEX_PATHS = (
    DOCS_README,
    DOCS / "knowledge" / "harness-design-principles.md",
)
PLANNING_SKILL_PATHS = (
    DOT_CODEX / "skills" / "product-planning" / "SKILL.md",
    DOT_CODEX / "skills" / "implementation-planning" / "SKILL.md",
)
REQUIRED_REVIEW_ENTRIES = (
    "quality-reviewer",
    "security-reviewer",
    "product-planning-reviewer",
    "implementation-planning-reviewer",
    "review-findings-summary",
)
REVIEW_REMOVED_ENTRYPOINTS = ("code-review",)
AUTO_SECURITY_PATTERNS = (
    "security-reviewer を追加する",
    "security-reviewer` を追加する",
    "必要な場合だけ `security-reviewer` を追加する",
    "必要時だけ `security-reviewer` を追加する",
)


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


def collect_readme_links(target_dir: Path) -> set[str]:
    linked_docs = set()
    readme_text = DOCS_README.read_text()
    for match in MARKDOWN_LINK_RE.finditer(readme_text):
        target = match.group(1).split("#", 1)[0]
        if not target.endswith(".md"):
            continue
        resolved = (DOCS_README.parent / target).resolve()
        if resolved.parent == target_dir:
            linked_docs.add(resolved.name)
    return linked_docs


def check_docs_readme_index() -> None:
    for target_dir in (KNOWLEDGE_DIR, ADR_DIR):
        existing_docs = {path.name for path in target_dir.glob("*.md")}
        linked_docs = collect_readme_links(target_dir)
        missing = sorted(existing_docs - linked_docs)
        if missing:
            fail(f"{DOCS_README.relative_to(ROOT)} is missing links to: {', '.join(missing)}")
    if "`dot_codex/agents/`" not in DOCS_README.read_text():
        fail(f"{DOCS_README.relative_to(ROOT)} must mention `dot_codex/agents/` as a review surface")


def check_skill_surface() -> None:
    skills_dir = DOT_CODEX / "skills"
    legacy_dirs = sorted(
        path.relative_to(ROOT)
        for path in skills_dir.iterdir()
        if path.is_dir() and (path.name == "entry-classify" or path.name.startswith(LEGACY_SKILL_DIR_PREFIXES))
    )
    if legacy_dirs:
        fail(f"legacy skill directories remain: {', '.join(map(str, legacy_dirs))}")

    for path in sorted(skills_dir.rglob("SKILL.md")):
        text = path.read_text()
        if LEGACY_SKILL_NAME_RE.search(text):
            fail(f"{path.relative_to(ROOT)} still declares a legacy skill prefix in frontmatter")


def check_review_surface() -> None:
    code_review_skill = DOT_CODEX / "skills" / "code-review" / "SKILL.md"
    if code_review_skill.exists():
        fail(f"{code_review_skill.relative_to(ROOT)} must be removed")

    for path in REVIEW_FULL_ENTRY_PATHS:
        text = path.read_text()
        for entry in REQUIRED_REVIEW_ENTRIES:
            if entry not in text:
                fail(f"{path.relative_to(ROOT)} must mention review entry `{entry}`")
        for removed in REVIEW_REMOVED_ENTRYPOINTS:
            if removed in text:
                fail(f"{path.relative_to(ROOT)} still references removed review skill `{removed}`")
        for pattern in AUTO_SECURITY_PATTERNS:
            if pattern in text:
                fail(f"{path.relative_to(ROOT)} must not imply automatic security escalation via `{pattern}`")

    for path in REVIEW_INDEX_PATHS:
        text = path.read_text()
        if "`dot_codex/agents/`" not in text:
            fail(f"{path.relative_to(ROOT)} must mention `dot_codex/agents/` as the review surface")
        if "agent-first" not in text and "明示的" not in text:
            fail(f"{path.relative_to(ROOT)} must describe explicit agent selection for review")
        for removed in REVIEW_REMOVED_ENTRYPOINTS:
            if removed in text:
                fail(f"{path.relative_to(ROOT)} still references removed review skill `{removed}`")

    for path in PLANNING_SKILL_PATHS:
        text = path.read_text()
        if "review を行わず" not in text and "review を行わない" not in text:
            fail(f"{path.relative_to(ROOT)} must state that the skill does not perform review")
        if "既定で起動" in text or "自動起動" in text:
            fail(f"{path.relative_to(ROOT)} must not claim automatic reviewer startup")

    review_summary = DOT_CODEX / "skills" / "review-findings-summary" / "SKILL.md"
    review_summary_text = review_summary.read_text()
    if "agent 出力" not in review_summary_text:
        fail(f"{review_summary.relative_to(ROOT)} must require agent output as input")
    if "fail closed" not in review_summary_text:
        fail(f"{review_summary.relative_to(ROOT)} must describe fail-closed behavior")
    for removed in REVIEW_REMOVED_ENTRYPOINTS:
        if removed in review_summary_text:
            fail(f"{review_summary.relative_to(ROOT)} must not reference removed review skill `{removed}`")

    review_scan_paths = [*sorted(DOT_CODEX.rglob("*.md")), *sorted(KNOWLEDGE_DIR.glob("*.md")), DOCS_README]
    for path in review_scan_paths:
        text = path.read_text()
        for removed in REVIEW_REMOVED_ENTRYPOINTS:
            if removed in text:
                fail(f"{path.relative_to(ROOT)} must not reintroduce removed review skill `{removed}`")


def main() -> None:
    check_agents()
    check_rules()
    check_markdown_links()
    check_docs_readme_index()
    check_skill_surface()
    check_review_surface()
    print("Codex harness verification passed.")


if __name__ == "__main__":
    main()
