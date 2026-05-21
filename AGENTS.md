# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない

## Codex スキルに関する作業

- Codex のスキルを新規作成する、既存スキルの設計を変更する、または description / trigger / 構成 / references / scripts / 品質評価について判断する場合は、判断前に必ず `skill-creator` スキルを使用する
- Agent Skills 公式情報は、スキル内容の検討・編集として、仕様、構造、description、progressive disclosure、best practice に関わる判断を行う時だけ開いて確認する。既存スキルの内容を読み取るだけの場合は必須としない
  - [Overview](https://agentskills.io/)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- `grill` スキルは、実装、設計、要件整理、仕様化の前に、共有理解へ到達するまで一問ずつ問い詰め、確定事項を doc / artifact に最小反映する時に使用する
- `scribe` スキルは、README、既存 docs、運用手順、設計メモ、PRD、要件定義、設計、実装計画、テストケース、traceability、CONTEXT、ADR などの doc / artifact 作成・更新・整形に使用する
- 実行条件、権限、停止線、reviewer 起動、スキル定義、agent 定義、承認ルール、runtime 設定に触れるファイルは、拡張子に関係なく docs-only と扱わない
- `scribe` 単独で進めない代表例:
  - root `AGENTS.md` と `dot_codex/private_AGENTS.md.tmpl`
  - `dot_codex/skills/**/SKILL.md`
  - `dot_codex/skills/**/references/`、`scripts/`、`assets/` のうち skill の判断や実行に影響するもの
  - `dot_codex/agents/*.toml`
  - `dot_codex/rules/*.rules`
  - `dot_codex/private_config.toml.tmpl` など Codex runtime 設定
- 誤字修正、単純な diff 確認、commit / push、合意済み文言の機械的反映、パスや現状確認だけの場合は、`skill-creator` や公式情報確認を必須とはしない。ただし、scripts / references / trigger / 権限 / secret / 外部 I/O / 実行挙動に触れる変更は除く
- Agent Skills 公式情報を確認した場合は、最終返答で参照した公式ページを簡潔に明示する。確認が必要だったが確認できない場合は、その事実と理由を明示し、進め方を相談する
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

## 置き場の原則

- `dot_codex/skills/`: 再利用する作業手順と通常作業の正式入口を置く
- `docs/notes/`: repo-level の通常知見や背景を置く
- `docs/adr/`: repo-level の判断記録を置く
- `dot_codex/private_AGENTS.md.tmpl`: deployable artifact 側の運用契約を置く
