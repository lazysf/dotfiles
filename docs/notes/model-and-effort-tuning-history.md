# Model and Effort Tuning History

> **Scope**: 時系列の履歴記録。各エントリは記録時点の model / effort / agent 構成を反映し、廃止済みの agent（例: `inspector`、ADR 0035 で廃止）への言及も当時の履歴。現行の構成は ADR 0036 / [lightweight-workflow.md](./lightweight-workflow.md) を正本にする。

Claude / Codex の model と reasoning effort を調整してきた経緯を、後で「なぜこの配分か」を辿れるように時系列で残す。2026-06-03 の 3 章 (Opus 4.6 pin / Codex effort 調整 / Claude effort 統合) は `docs/requests/` から退避した詳細を要約しており、それ以降は本 notes に直接記録する。

## 2026-06-03: Claude model を Opus 4.6 に pin

- commit: [000e713](https://github.com/lazysf/dotfiles/commit/000e713) `chore: pin Claude model to Opus 4.6`
- 動機: main session と全 custom agent を `opus` alias から `claude-opus-4-6` に pin して、aliases の解決ぶれを排除。
- 変更:
  - `dot_claude/settings.json` の `model: opus` -> `model: claude-opus-4-6`
  - `dot_claude/agents/*.md` frontmatter `model: opus` -> `model: claude-opus-4-6`
- effort は据え置き。

## 2026-06-03: Codex の reasoning effort を調整

- commit: [91a259c](https://github.com/lazysf/dotfiles/commit/91a259c) `chore: tune Codex reasoning effort`
- 方針: main を品質寄せ (`high`)、researcher は事実調査中心として軽く (`medium`)。`gpt-5.5` は維持。
- 変更後の Codex 配分:
  - main: `gpt-5.5` / `high`
  - researcher: `gpt-5.5` / `medium`
  - その他 agent: 既存の `high` / `medium` のまま

## 2026-06-03: Claude effort を Codex に揃える

- commit: [6f2c7be](https://github.com/lazysf/dotfiles/commit/6f2c7be) `chore: align Claude effort with Codex`
- 動機: Claude と Codex を非対称に運用してきたが、effort 配分を Codex 側に合わせて統一。
- 変更後の Claude 配分:
  - main: `high` (据え置き)
  - researcher: `low` -> `medium`
  - requirements / design / quality reviewer: `medium` -> `high`
  - security reviewer: `high` (据え置き)
  - inspector: `medium` (据え置き)
- model は `claude-opus-4-6` のまま。

## 2026-06-06: Claude model を Opus 4.7 (1M context) に更新

- commit: [39afb34](https://github.com/lazysf/dotfiles/commit/39afb34) `chore: pin Claude model to Opus 4.7 (1M context)`
- 動機: 大規模 diff / file の取り回しを楽にするため 1M context を採用。Opus 4.7 への version up も同時に。
- 変更:
  - `dot_claude/settings.json.tmpl` の `model` を `claude-opus-4-6` -> `claude-opus-4-7[1m]`
  - `dot_claude/agents/{quality-reviewer,security-reviewer,researcher}.md` frontmatter も同様に更新
- 注意: `[1m]` suffix は 2026-06 時点で Claude Code 公式 docs に明示掲載なし。実機で挙動を確認のうえ採用している。`[1m]` で起動できない場合は `claude-opus-4-7` (通常 context) へ fallback する判断余地を残す。
- effort は据え置き。

## 2026-06-18: Claude model を Opus 4.7 (通常 context) に戻し、effort を公式 default 寄せに

- commit: [0ebe6e4](https://github.com/lazysf/dotfiles/commit/0ebe6e4) `chore: pin Claude model to Opus 4.7 and tune effort to xhigh`
- 動機:
  - `[1m]` suffix を外し Opus 4.7 + 通常 context に揃える。Claude Code UI で実際に選んでいる model (Opus 4.7 高速) と settings.json の宣言を一致させ、起動毎に意図しない model に巻き戻る挙動を避ける。
  - effort は Opus 4.7 公式推奨（"xhigh for coding/agentic, minimum high for intelligence-sensitive"）に寄せる。前回の Codex 寄せでコスト側に倒していたが、Opus 4.7 では `low`/`medium` で under-thinking する可能性があるため見直し。
- 変更:
  - `dot_claude/settings.json.tmpl` の `model` を `claude-opus-4-8[1m]` -> `claude-opus-4-7`、`effortLevel` を `medium` -> `xhigh`
  - `dot_claude/agents/quality-reviewer.md` frontmatter: `model` 同様、`effort: high` -> `xhigh`
  - `dot_claude/agents/security-reviewer.md` frontmatter: `model` 同様、`effort: high` -> `xhigh`
  - `dot_claude/agents/researcher.md` frontmatter: `model` 同様、`effort: low` -> `medium`
- Codex 側 (`dot_codex/`) の effort は据え置き。Claude と Codex の effort 配分は今回非対称になる。
- 注意: 高速モード (`/fast`) は settings.json で永続化する公式手段が未確認。現状は session 毎に UI / `/fast` で切替する運用。

## 2026-07-28: Claude model を Opus 5 に更新

- 動機: main session と全 custom agent を Opus 5 に上げる。従来どおり alias ではなく full model ID で pin し、解決ぶれを排除。
- 変更:
  - `dot_claude/settings.json.tmpl` の `model` を `claude-opus-4-7` -> `claude-opus-5`
  - `dot_claude/agents/{quality-reviewer,security-reviewer,researcher}.md` frontmatter も同様に更新
  - `dot_claude/agents/researcher.md` frontmatter `effort` を `medium` -> `high`
- effort 見直しの根拠:
  - Opus 4.7 の default effort は `xhigh` だったが、**Opus 5 の default は `high`**。さらに公式が「The effort scale is calibrated per model, so the same level name does not represent the same underlying value across models」と明記しているため、4.7 時代の配分をそのまま持ち越す根拠は弱い。
  - `researcher` の `medium` は 2026-06-18 の「Codex 寄せ / コスト側に倒す」判断由来で、model 特性由来ではなかった。役割（影響範囲・挙動の調査）は網羅性が効き、取りこぼしが lead 側の誤判断に直結するため、Opus 5 default と同じ `high` に戻す。
  - `quality-reviewer` / `security-reviewer` の `xhigh` は維持。default より一段上を意図的に取る。
  - main の `effortLevel: xhigh` も維持。Opus 5 では default `high` に対する意図的な一段上げになる。
- `max` は採用しない。subagent frontmatter では受け付けるが（settings.json は不可）、公式が "may show diminishing returns and is prone to overthinking. Test before adopting broadly" と警告している。
- 注意:
  - Opus 5 は Claude Code v2.1.219 以降が必要（公式 docs 記載）。古い client では選択できない。
  - Opus 4.7 / 4.8 と違い、Opus 5 は「初回起動時に model 既定 effort へ寄せる hold」を持たない。既存の `effortLevel: xhigh` がそのまま引き継がれる。
  - Codex 側 (`dot_codex/`) の effort は据え置き。researcher の effort は Claude `high` / Codex `low` で非対称のまま。

## 過去 request の所在

| 退避前 path | 主題 |
| --- | --- |
| `docs/requests/change-claude-model-opus-46/` | Opus 4.6 pin |
| `docs/requests/tune-codex-reasoning-effort/` | Codex effort 調整 |
| `docs/requests/align-claude-effort-with-codex/` | Claude effort を Codex に揃える |

詳細な `request.md` / `implementation.md` / `review.md` / `test.md` はこの notes に集約後、削除した。判断 (ADR) ではなく経緯記録なので notes に置く。
