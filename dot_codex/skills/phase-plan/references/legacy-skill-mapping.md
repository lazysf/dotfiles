# Layer Mapping

- `entry-classify` -> 全導線の共通入口
- `workflow-*` -> 分類後の案件タイプ別導線
- `phase-plan` / `phase-implement` / `phase-review` / `phase-commit` / `phase-publish` -> 共通工程
- `phase-diagnose` / `phase-verify` など -> 分類別 workflow で使う工程
- `core-*` -> 各工程の詳細手順、判断基準、停止条件

現在は旧名を併記せず、`entry-classify` / `workflow-*` / `phase-*` / `core-*` の命名へ一本化する。
