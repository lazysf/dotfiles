# README 形式

README を作成・更新する時に読む。repo root の `README.md` と `docs/README.md` で書くものが違う。

## 共通

- 既存の章構成、並び順、粒度があればそれを優先する。
- リンクは README からの相対 path にする。
- 追加、削除、rename、移動した対象と一覧の整合を確認する。
- 一時メモ、秘密情報、認証情報、private config、未公開の個人情報を載せない。

## repo root の `README.md`

読み手は、初めて使う利用者。repo が何であるか、前提、導入手順、使い方、利用者の判断に効く注意を書く。

開発に加わる人に向けた内容は書かない。次のものは、それぞれの置き場に書く。

| 内容 | 置き場 |
| --- | --- |
| 開発の手順（環境構築、lint、試験、branch の運用） | `CONTRIBUTING.md` |
| 判断の理由 | ADR |
| 調査の経緯 | notes |
| docs 配下の artifact 一覧 | `docs/README.md` |

配る側の事情（例: 版がどう決まるか）は、利用者の判断に効かないので、README には書かない。

- 道具の一般的な使い方は書かない。判定は「この文は、同じ道具を使うどの project でも同じか」。同じなら公式 docs に任せ、project に固有のコマンドと名前だけを書く。
- 手順は、読み手の環境で成り立つ形にする。開発者の repo 内の相対パスは、配られた先に無いことがある。書いた手順は、利用者と同じ環境で、書いた形のまま一度通す。
- README から外した内容のうち、project に固有の事実で理由が要るものは notes へ移す。「なぜ README に書かないか」も notes に残す。道具の一般的な内容は移さない。

形は repo の性質で変わるのでテンプレートを固定しない。既存の README があるなら、その構成を崩さずに追記する。形に迷ったら、同じ種類の project の README を数件見て、載っている範囲を目安にする。

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
