# Docs README 形式

`docs/README.md` を作成・更新する時に使う。
docs 配下の artifact 体系だけを案内する。

## Rules

- 詳細本文、判断理由、読み順、運用手順を転載しない。
- 既存の章構成、並び順、粒度があればそれを優先する。
- リンクは README からの相対 path にし、各項目は 1 行説明に留める。
- directory は配下の artifact 群の責務を書く。
- 追加、削除、rename、移動した artifact と一覧の整合を確認する。
- 一時メモ、秘密情報、private config、未公開個人情報を載せない。

## Template

```markdown
# docs

[この `docs/` の artifact 体系を 1 文で説明する。]

- [artifact.md](./artifact.md): [artifact の種類と目的。]
- `docs/[category]/`: [配下の artifact 群の責務。]
  - [example.md](./[category]/example.md): [artifact の種類と目的。]
- `docs/adr/`: [判断記録。]
  - [0001-example-decision.md](./adr/0001-example-decision.md): [判断の対象。]
```
