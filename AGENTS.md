# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない

## Codex スキルに関する作業

- Codex のスキルを新規作成する、既存スキルの設計を変更する、または description / trigger / 構成 / references / scripts / 品質評価について判断する場合は、判断前に必ず `skill-creator` スキルを使用する
- Agent Skills の仕様、構造、description、progressive disclosure、best practice に関わる判断を行う時は、Agent Skills 公式情報を開いて確認する
  - [Overview](https://agentskills.io/)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- 誤字修正、単純な diff 確認、commit / push、合意済み文言の機械的反映、パスや現状確認だけの場合は、`skill-creator` や公式情報確認を必須とはしない。ただし、scripts / references / trigger / 権限 / secret / 外部 I/O / 実行挙動に触れる変更は除く
- 公式情報を確認できない場合は、確認できなかった事実と理由をユーザーに明示し、進め方を相談する
- Agent Skills 公式情報を確認した場合は、最終返答で参照した公式ページを簡潔に明示する。確認が必要だったが確認できなかった場合は、その事実と理由を明示する
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

## 置き場の原則

- `dot_codex/skills/`: 再利用する作業手順と通常作業の正式入口を置く
- `docs/knowledge/`: repo-level の通常知見や背景を置く
- `docs/adr/`: repo-level の判断記録を置く
- `dot_codex/AGENTS.md`: deployable artifact 側の運用契約を置く
