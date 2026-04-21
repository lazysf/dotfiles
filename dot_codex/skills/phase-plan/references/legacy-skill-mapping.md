# Layer Mapping

- `entry-classify` -> `core-task-classification` への deprecated wrapper
- `phase-plan` -> `core-request-shaping` / `core-task-intake` / `core-product-planning` / `core-implementation-planning`
- `phase-review` -> `core-code-review` / `core-review-findings-summary`
- `phase-commit` -> `core-git-commit`
- `phase-publish` -> `core-git-push`
- `phase-research` -> `core-research`
- `phase-diagnose` -> `core-bug-diagnosis`
- `phase-implement` -> `core-code-implementation-loop`
- `phase-test` -> `core-change-testing`
- `phase-verify` -> `core-change-verification`
- `phase-quality-analysis` -> `core-quality-analysis`
- `phase-security-scan` -> `core-security-scan`
- `phase-compat-assessment` -> `core-compat-assessment`
- `phase-maintenance-analysis` -> `core-maintenance-analysis`
- `phase-capture-knowledge` -> `core-capture-knowledge-triage` / `core-write-knowledge-note` / `core-write-adr`

現在の正式入口は `core-*` とし、`entry-*` / `phase-*` は互換表でのみ扱う。
