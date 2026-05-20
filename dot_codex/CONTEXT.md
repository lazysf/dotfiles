# Codex ハーネス

Codex ハーネス context は、`dot_codex/` で管理する deployable な Codex runtime surface を定義する。
chezmoi で展開した後も、運用指示、再利用 skill、agent、rule、plugin 設定、安全境界を一貫させるために存在する。

## Language

**Codex ハーネス**: `dot_codex/` 配下に置く deployable な Codex runtime surface。
_Avoid_: dotfiles docs, repo knowledge

**Runtime Surface**: 展開後の Codex の振る舞いに影響する、ユーザー向けまたは agent 向けの入口。
_Avoid_: documentation set, implementation detail

**Runtime Surface Size**: Codex 関連設定として管理する `AGENTS.md`、`SKILL.md`、agent 定義、rule、runtime config などの記載量。
_Avoid_: docs-only volume

**Runtime Context Cost**: 実行時に agent の文脈へ入る確率と量で重み付けした記載コスト。
_Avoid_: raw file size only

**Runtime Precision**: 適切な surface の発火精度と、発火後の判断、出力、変更、報告の正確さを合わせた実行時品質。
_Avoid_: trigger accuracy only, verbosity

**Runtime Output Quality**: 実行時の返答や成果物が、根拠を持ち、読みやすく、目的に必要十分で、余計なノイズが少ない度合い。
_Avoid_: correctness only, polish only

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
- **Runtime Context Cost** は、Codex 関連設定のブラッシュアップで減らしたい分母である。
- **Runtime Surface Size** は **Runtime Context Cost** を下げるための主要な制御対象であり、実ファイルの記載量が少ないほど実行時に文脈へ入る量も小さくなりやすい。
- **Runtime Precision** は、**Runtime Context Cost** を増やせば必ず上がるものではなく、発火境界、停止線、検証入口、出力契約の明確さに左右される。
- **Runtime Output Quality** は **Runtime Precision** と重なるが、正確さに加えて根拠、読みやすさ、十分性、ノイズの少なさを含む。
- **Reviewer Agent** は draft や diff を review するが、ファイルは変更しない。
- **Rule** は機械的な command 実行を guard するもので、workflow 判断の代替ではない。
- **Deployable Artifact** は、**Knowledge Ledger** の accepted decision によって形が変わることがある。

## Example dialogue

> **Maintainer:** 「この繰り返し使う planning 挙動は Skill にするべき？ note にするべき？」
> **Domain expert:** 「workspace 横断で Codex の振る舞いを変えるなら Skill。理由の説明だけなら Knowledge Ledger に置く。」

## Flagged ambiguities

- 「docs」は `dot_codex/` 内の deployable instructions と、`docs/` 配下の repo-level knowledge の両方を指しうる。Resolved: 前者は **Deployable Artifact**、後者は Knowledge Ledger の用語で呼ぶ。
