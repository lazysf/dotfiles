# README 形式

README を作成・更新する時に読む。repo root の `README.md` と `docs/README.md` で書くものが違う。

## 共通

- 既存の章構成、並び順、粒度があればそれを優先する。
- リンクは README からの相対 path にする。
- 追加、削除、rename、移動した対象と一覧の整合を確認する。
- 一時メモ、秘密情報、認証情報、private config、未公開の個人情報を載せない。

## repo root の `README.md`

読み手は、初めて使う利用者。repo が何であるか、前提、導入手順、使い方、利用者の判断に効く注意を書く。

### 構成

既存の README があれば、その章立てを崩さずに追記する。無い時は次の構成にする。見出しの言語は repo に合わせる。

```markdown
# [名前]

[何であるかを 1 文。package の description と揃える。]

[状態の注意があれば 1 文。実験的、保守していない、など。]

## 前提

## 導入

## 使い方

## 構成

## 助けと貢献

## ライセンス
```

- 必ず書くのは、1 文の説明、導入、使い方、助けと貢献、ライセンス。[Standard Readme](https://github.com/RichardLitt/standard-readme/blob/main/spec.md)、[GitHub の About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)、[Open Source Guide](https://opensource.guide/starting-a-project/) が共通して求める範囲。
- 前提と構成は、書くことがある時だけ置く。
- 助けと貢献には、質問の先と、貢献を受け付けるかを書く。`SUPPORT.md` や `CONTRIBUTING.md` があれば指す。受け付けないなら、その旨を 1 文で書く。どちらも repo から読めない時は、推測で書かず、空の節も置かずに、ユーザーに聞く。
- ライセンスは最後に置く。名前か SPDX の識別子と、`LICENSE` への指し先を書く。

### 書く規則

開発に加わる人に向けた内容（開発の手順、判断の理由、調査の経緯）は書かない。置き場は `../SKILL.md` の「置き場の選び方」の表に従う。

配る側の事情（例: 版がどう決まるか）は、利用者の判断に効かないので、README には書かない。

- 道具の一般的な使い方は書かない。判定は「この文は、同じ道具を使うどの project でも同じか」。同じなら公式 docs に任せ、project に固有のコマンドと名前だけを書く。
- 手順は、読み手の環境で成り立つ形にする。開発者の repo 内の相対パスは、配られた先に無いことがある。
- README から外した内容のうち、project に固有の事実で理由が要るものは notes へ移す。「なぜ README に書かないか」も notes に残す。道具の一般的な内容は移さない。
- 構成の節は、トップの階層の地図（directory やファイルが何かを 1 行ずつ）に留める。内部の構成（module の責務と境界）は `DEVELOPMENT.md` に書く。
- 詳しい使い方と一覧が README に収まらない時は、`docs/` に置いて README から指す。

## `docs/README.md`

docs 配下の artifact 体系だけを案内する。

### 構成

```markdown
# docs

[この `docs/` の artifact 体系を 1 文で説明する。]

- [artifact.md](./artifact.md): [artifact の種類と目的。]
- `docs/[category]/`: [配下の artifact 群の責務。]
  - [example.md](./[category]/example.md): [artifact の種類と目的。]
- `docs/adr/`: [判断記録。]
  - [0001-example-decision.md](./adr/0001-example-decision.md): [判断の対象。]
```

### 書く規則

- 詳細本文、判断理由、読み順、運用手順を転載しない。案内に徹する。
- 各項目は 1 行説明に留める。
- directory は配下の artifact 群の責務を書く。
- ADR は件数が増えるため、1 行説明を省いて path だけ並べてもよい。その場合もタイトルが決定内容を表していれば案内として足りる。
