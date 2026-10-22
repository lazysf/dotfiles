# Codex harness の運用

- Date: 2026-10-08
- 出典: [Permissions](https://learn.chatgpt.com/docs/permissions) / [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Build skills](https://learn.chatgpt.com/docs/build-skills) / [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic) / 一時領域への chezmoi 展開と Codex CLI 0.162.0-alpha.2 での設定読み込みの確認（2026-10-08） / 移植時の Codex CLI 0.160.0 でのスキル発見の確認

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版。運用契約は [`dot_codex/AGENTS.md`](../../dot_codex/AGENTS.md) にある。`config.toml` はこの repo で管理・配布しない。再導入の判断は [ADR 0043](../adr/0043-reintroduce-codex-from-current-claude.md)、`config.toml` を管理しない判断は [ADR 0044](../adr/0044-manage-codex-runtime-config-per-device.md) にある。

## 構成と権限

skills は [`skills/`](../../dot_codex/skills/)、reviewer は [`agents/`](../../dot_codex/agents/) に置く。通常作業のモデル、effort、権限、自動 memory は実機側の設定に委ねる。reviewer は親のモデル選択に依存せず、`gpt-6.1-sol` を使う。effort は品質 reviewer が `high`、security reviewer が `xhigh`。通常の応答には `caveman` skill を使う。

reviewer の既定の権限は標準の `:read-only`。credential store などへの独自の deny 設定は、この標準プロファイルには追加していない。

親のセッションで変更した sandbox と承認設定は、子の起動時にも適用される。reviewer の `default_permissions = ":read-only"` と `approval_policy = "never"` より優先される場合がある。reviewer を使う際は、設定ファイルの既定値だけで読み取り専用と判断せず、実効権限を確認する。

[`destructive.rules`](../../dot_codex/rules/destructive.rules) は、列挙したディスク操作コマンドを sandbox 外で禁止する設定。コマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応する。未知の `mkfs.*` / `newfs_*` や任意の script は網羅しない。契約と設定は管理者による強制ではない。

## 検証範囲

2026-10-08 に macOS・Linux・Windows の 3 通りの OS 分岐で、一時領域への chezmoi 展開を確認した。`config.toml` は管理対象から除外される。既存 config の内容は保持され、存在しない場合も作成されない。AGENTS、skills、agents、rules の配布は継続する。macOS 上の Codex CLI 0.162.0-alpha.2 では、独自の `protected` がなくても両 reviewer のモデル・権限設定が読み込めることを確認した。

移植時の記録では、Codex CLI 0.160.0 の一時 home で `~/.codex/skills/` 相当のスキル発見を確認している。公式の user skill 配置は `~/.agents/skills/`。client 更新後はスキル発見を再確認する。

## 適用前後の確認

配布前に `chezmoi diff ~/.codex` で内容を確認する。`config.toml` は `.chezmoiignore` で除外しているため、chezmoi は作成・更新・削除しない。過去に配布した config も自動では消えない。

MCP、plugin、通知、モデル、権限などは、アプリまたは実機の `~/.codex/config.toml` で管理する。既存 config を手動で削除・変更する場合は、必要な追加設定を事前に退避する。個人や作業機を特定する値、秘密情報を repo の source へ取り込まない。

適用後は `chezmoi managed` と target の実体を突き合わせる。source から削除したファイルが target に残る場合がある。

実機の権限設定を変更したら、設定を読み直した新しいセッションで必要な作業とアクセス境界を検証する。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しない。

## 未確認

- reviewer の実際の起動。
- Windows 実機での動作。
