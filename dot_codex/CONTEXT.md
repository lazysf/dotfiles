# Codex ハーネス

Codex ハーネス context は、`dot_codex/` で管理する deployable な Codex runtime surface を定義する。
chezmoi で展開した後も、運用指示、再利用 skill、agent、rule、plugin 設定、安全境界を一貫させるために存在する。

## Language

**Codex ハーネス**: `dot_codex/` 配下に置く deployable な Codex runtime surface。
_Avoid_: dotfiles docs, repo knowledge

**Runtime Surface**: 展開後の Codex の振る舞いに影響する、ユーザー向けまたは agent 向けの入口。
_Avoid_: documentation set, implementation detail

**Skill**: `dot_codex/skills/` 配下に置く再利用可能な workflow。`SKILL.md` の trigger description と手順を持つ。
_Avoid_: command, phase, wrapper

**Reviewer Agent**: focused review に使う、`dot_codex/agents/` 配下の read-only な専門 agent。
_Avoid_: skill reviewer, automatic review

**Rule**: 狭い command pattern を許可する、`dot_codex/rules/` 配下の機械的 guard。
_Avoid_: policy note, prose instruction

**Deployable Artifact**: chezmoi により `~/.codex` へ展開されることを意図したファイル。
_Avoid_: repo note, design record

**Operational Boundary**: mutation、外部影響、破壊的操作、scope 拡大を制限する安全境界。
_Avoid_: preference, reminder

## Relationships

- **Skill** は **Runtime Surface** の一部である。
- **Reviewer Agent** は draft や diff を review するが、ファイルは変更しない。
- **Rule** は機械的な command 実行を guard するもので、workflow 判断の代替ではない。
- **Deployable Artifact** は、**Knowledge Ledger** の accepted decision によって形が変わることがある。

## Example dialogue

> **Maintainer:** 「この繰り返し使う planning 挙動は Skill にするべき？ note にするべき？」
> **Domain expert:** 「workspace 横断で Codex の振る舞いを変えるなら Skill。理由の説明だけなら Knowledge Ledger に置く。」

## Flagged ambiguities

- 「docs」は `dot_codex/` 内の deployable instructions と、`docs/` 配下の repo-level knowledge の両方を指しうる。Resolved: 前者は **Deployable Artifact**、後者は Knowledge Ledger の用語で呼ぶ。
