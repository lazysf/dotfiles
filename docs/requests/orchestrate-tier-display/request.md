# Request

## 元の要求・要望

- 「orchestrateスキルで進める際，最初にどの分岐フロー（tier）で進めるか表示させたい」
- 「もう一度，0から判定して進めろ」

## 背景

- 直前の作業では `tier: standard` と表示した後、standard flow で必須の `request.md` を作成せずに `dot_codex/skills/orchestrate/SKILL.md` を編集した。
- ユーザーは、その進行が手順違反であると指摘した。
- 今回は Phase 0 から再判定し、該当 tier の flow に沿って進める。

## 期待状態

- `orchestrate` skill 使用時、Phase 0 の triage 直後に、どの tier で進めるかと根拠が最初にユーザーへ表示される。
- 変更作業自体も、判定した tier の artifact / checkpoint に沿って進む。

## 不明点

- なし。

## 再定義履歴

なし。
