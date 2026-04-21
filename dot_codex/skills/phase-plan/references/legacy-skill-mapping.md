# Layer Mapping

- `workflow-*` -> 案件タイプごとの入口
- `phase-plan` / `phase-implement` / `phase-review` / `phase-commit` / `phase-publish` -> 共通工程
- `phase-classify` / `phase-diagnose` / `phase-verify` など -> 分類別 workflow で使う工程
- `core-*` -> 各工程の詳細手順、判断基準、停止条件

現在は旧名を併記せず、`workflow-*` / `phase-*` / `core-*` の命名へ一本化する。
