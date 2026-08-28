# README 形式

README を作成・更新する時に読む。repo root の `README.md` と `docs/README.md` で書くものが違う。

## 共通

- 既存の章構成、並び順、粒度があればそれを優先する。
- リンクは README からの相対 path にする。
- 追加、削除、rename、移動した対象と一覧の整合を確認する。
- 一時メモ、秘密情報、認証情報、private config、未公開の個人情報を載せない。

## repo root の `README.md`

repo が何であるか、どう使うかを書く。導入手順、前提、主要な構成。読み手は repo を初めて触る人。

判断理由は書かない（ADR）。調査の背景も書かない（notes）。docs 配下の artifact 一覧も書かない（`docs/README.md`）。

形は repo の性質で変わるのでテンプレートを固定しない。既存の README があるなら、その構成を崩さずに追記する。

## `docs/README.md`

docs 配下の artifact 体系だけを案内する。

- 詳細本文、判断理由、読み順、運用手順を転載しない。案内に徹する。
- 各項目は 1 行説明に留める。
- directory は配下の artifact 群の責務を書く。

```markdown
# docs

[この `docs/` の artifact 体系を 1 文で説明する。]

- [artifact.md](./artifact.md): [artifact の種類と目的。]
- `docs/[category]/`: [配下の artifact 群の責務。]
  - [example.md](./[category]/example.md): [artifact の種類と目的。]
- `docs/adr/`: [判断記録。]
  - [0001-example-decision.md](./adr/0001-example-decision.md): [判断の対象。]
```

ADR は件数が増えるため、1 行説明を省いて path だけ並べてもよい。その場合もタイトルが決定内容を表していれば案内として足りる。
