# 共通ハーネス構成

`dot_codex/` は、どの workspace に展開しても同じように使える共通ハーネスを管理します。

## 構成

- [AGENTS.md](../AGENTS.md)
  - 共通運用契約
- [QUICKSTART.md](../QUICKSTART.md)
  - 日常の入口索引
- [HIGH_QUALITY_VIBE_CODING.md](../HIGH_QUALITY_VIBE_CODING.md)
  - 実務ガイド
- [private_config.toml.tmpl](../private_config.toml.tmpl)
  - Codex の既定設定
- [rules/](../rules/)
  - 実行ガードレール
- [skills/](../skills/)
  - 再利用可能な作業単位
- [agents/](../agents/)
  - specialized review agents

## 責務分担

- 入口の説明は `QUICKSTART.md`
- 正式な運用契約は `AGENTS.md`
- 実装・運用の具体例は `HIGH_QUALITY_VIBE_CODING.md`
- 実行挙動の制御は `private_config.toml.tmpl` と `rules/`
- 継続利用するノウハウは `skills/`

## 設計方針

- 共通ハーネスには project-specific knowledge を持ち込まない
- repo-level の設計履歴は `dot_codex/` ではなく保守元の repo で管理する
- 実装されていない Codex 機能には依存しない
