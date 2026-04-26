# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない

## Codex スキルに関する作業

- Codex のスキルに関する相談、方針整理、計画作成、実装、編集、レビュー前確認では、判断前に必ず `skill-creator` スキルを使用する
- スキルに関する判断や作業を行う時は、相談、計画、実装、編集の各段階で必要に応じて Agent Skills 公式情報を開いて確認する
  - [Overview](https://agentskills.io/)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- 公式情報を確認できない場合は、確認できなかった事実と理由をユーザーに明示し、進め方を相談する
- 最終返答では、参照した公式ページ、または公式情報を確認できなかった事実を簡潔に明示する
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

## 置き場の原則

- `dot_codex/skills/`: 再利用する作業手順と通常作業の正式入口を置く
- `docs/knowledge/`: repo-level の通常知見や背景を置く
- `docs/adr/`: repo-level の判断記録を置く
- `dot_codex/AGENTS.md`: deployable artifact 側の運用契約を置く
