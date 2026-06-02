# Request

## 元の要求・要望

Claudeのエージェント含むモデルの設定を変更したい．Opur4．6を使う．effortはそのまま

## 背景

- Claude Code の設定変更に関する依頼。
- Claude Code 公式 docs で、main model は `settings.json` の `model` field、subagent model は agent frontmatter の `model` field で設定できることを確認した。
- Claude Code 公式 docs で、Opus 4.6 の full model ID として `claude-opus-4-6` が使われていることを確認した。
- 既存設定では `dot_claude/settings.json` と `dot_claude/agents/*.md` が `opus` alias を使っている。

## 期待状態

- Claude Code main session の model が `claude-opus-4-6` に pin されている。
- Claude Code custom agents の model が `claude-opus-4-6` に pin されている。
- `effortLevel` と各 agent の `effort` は既存値のまま。

## 不明点

- なし。

## 再定義履歴

- なし。

## Scope / Acceptance

- `dot_claude/settings.json` の `model` を `claude-opus-4-6` に変更する。
- `dot_claude/agents/*.md` の frontmatter `model` を `claude-opus-4-6` に変更する。
- `effortLevel` と `effort` は変更しない。
- JSON と agent frontmatter の設定値を確認する。

## 実装境界 / 省略理由 / 検証入口

- `requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` は省略する。理由: 既存設定値の機械的な pin 変更で、追加設計や task 分解が不要。
- 検証入口: `jq` による `dot_claude/settings.json` の JSON parse、`rg` による model / effort 設定確認、`git diff --check`。
