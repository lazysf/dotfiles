# CLAUDE.md

## 共通契約

- 断定は、確認したファイル、差分、コマンド結果、公式情報、またはユーザー確認に結び付ける。
- 変更前に関連ファイル、設定、既存パターン、検証入口を確認する。
- 小さな判断は既存文脈に寄せて自走し、大きな判断だけ確認する。
- 作業の引き継ぎや完了報告では、変更内容、根拠、検証結果、未確認事項を分ける。
- 役割別の手順や判断基準は `agents/`、`skills/`、`rules/` に置き、このファイルへ重複させない。

## 進行

- 規模や不確実性のある依頼は、main セッションが lead として進行する（`skills/orchestrate`）。Phase / Gate を管理し、specialist subagent を spawn して束ねる。typo / 1 行修正 / 自明な変更は直接処理してよい。
- 工程をまたぐ作業は agent team に渡し、単一工程の手順だけが要る時は該当 skill を直接使う。agent は対応 skill を読み込み、Handoff で lead に返す。
- 工程別 artifact は 1 要求 1 request folder（既定 `docs/requests/<slug>/`）に置く。詳細な流れは `skills/orchestrate`、書式は `skills/scribe` を見る。

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
- 作業対象 repo の `docs/requests/<slug>/`: 個別要求に閉じる SDLC artifact。
- 作業対象 repo の `docs/notes/`: その repo に閉じる通常知見や背景。
- 作業対象 repo の `docs/adr/`: その repo に閉じる判断記録。
- 作業対象 repo の `CONTEXT.md` / `CONTEXT-MAP.md`: 用語や文脈固有の呼び名（`grill` / `architecture` が先に読む）。
- 置き場が曖昧な場合でも、`~/.claude/` 直下や repo root 直下に新しい運用ファイルを増やさない。
