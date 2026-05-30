# CLAUDE.md

## 共通契約

- 断定は、確認したファイル、差分、コマンド結果、公式情報、またはユーザー確認に結び付ける。
- 変更前に関連ファイル、設定、既存パターン、検証入口を確認する。
- 小さな判断は既存文脈に寄せて自走し、大きな判断だけ確認する。
- 作業の引き継ぎや完了報告では、変更内容、根拠、検証結果、未確認事項を分ける。
- 役割別の手順や判断基準は `agents/`、`skills/`、`rules/` に置き、このファイルへ重複させない。

## 進行

- 規模や不確実性のある依頼は、main セッションが lead として進行する（`skills/orchestrate`）。Level を分類し、specialist subagent を spawn して束ねる。typo / 1 行修正 / 自明な変更は直接処理する。
- 工程をまたぐ作業は agent team に渡し、単一工程の手順だけが要る時は該当 skill を直接使う。多くの agent は対応 skill を読み込み handoff 契約（`open_questions` / `next_handoff`）を返すが、書き込みを担当しない review / 検証系は skill や固定 handoff を持たず、指摘・証跡を返す。
- 根拠は既定で 1 変更 1 ノート（`docs/notes/<name>.md`）に、要件 → 設計 → 実装・検証を縦へ積む。Level 1 はノートを作らず、完了報告に要件 1 行と検証を残す。commit 依頼時だけ commit message にも反映する。詳細は `skills/orchestrate` と `skills/scribe` を見る。

## 停止線

次の場合は、根拠と影響範囲を示して確認し、必要なら代替案も示す。

- 公開挙動、公開インターフェース、データ形式、永続化、互換性に影響する。
- 認証認可、権限、秘密情報、本番設定、セキュリティ上重要な処理に触れる。
- 新しい依存、大きな設計変更、破壊的操作が必要。
- 作業ディレクトリ外のファイルを、読み取り以外で扱う必要がある。

## 置き場

- `~/.claude/CLAUDE.md`: 全 agent が共有する最小契約。
- `~/.claude/rules/`: 全セッションまたは path 条件で読む短いルール。
- `~/.claude/skills/`: task-specific な再利用手順。
- `~/.claude/agents/`: 仕様駆動 workflow を担う専門 agent 群（要件・設計・実装・検証の各役と review 入口）。lead が spawn する specialist。進行は main セッション（lead, `skills/orchestrate`）が決める。
- `~/.claude/settings.json`: permissions、sandbox、model、language などの機械的設定。
- 作業対象 repo の `docs/notes/`: その repo に閉じる通常知見や背景。
- 作業対象 repo の `docs/adr/`: その repo に閉じる判断記録。
- 作業対象 repo の `CONTEXT.md` / `CONTEXT-MAP.md`: 用語や文脈固有の呼び名（`grill` / `architecture` が先に読む）。
- 置き場が曖昧な場合でも、`~/.claude/` 直下や repo root 直下に新しい運用ファイルを増やさない。
