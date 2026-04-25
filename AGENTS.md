# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない

## Codex スキルの追加・編集

- Codex のスキルを追加または編集する依頼では、必ず `skill-creator` スキルを使用する
- スキル作成・更新時は、Agent Skills 公式情報を参照する
  - [Overview](https://agentskills.io/)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

## 置き場の原則

- `dot_codex/skills/`: 再利用する作業手順と通常作業の正式入口を置く
- `docs/knowledge/`: repo-level の通常知見や背景を置く
- `docs/adr/`: repo-level の判断記録を置く
- `dot_codex/AGENTS.md`: deployable artifact 側の運用契約を置く
