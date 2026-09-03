# notes 形式

notes を書く時に読む。「notes は現在の設計を書く」は `../SKILL.md` を正本にする。

## 置き場と命名

`docs/notes/` 直下にフラットに置く。ファイル名は内容を短く表す kebab-case。粒度が増えたら subdirectory で group 化する。**1 ファイル 1 話題。** 同じ主題が 2 ファイルに分かれると、読み手はどちらに答えがあるか分からない。

## 最小テンプレート

```markdown
# [タイトル]

- Date: YYYY-MM-DD
- 出典: [URL / command / file path / commit hash]

[本文。現在こうなっている理由、確認した事実、参照したい snippet。]
```

`Date` は内容を最後に確認した日。更新したら書き換える。

## ルール

- 推測でなく確認した事実を書く。出典（URL、command、ファイル path、commit hash）を添える。
- 実測値には測定日を書く。仕様は version を書く。どちらも後から古くなる。
- 公開 IF、API、設定の正規仕様は notes に書かず、README / docs に書く。
- 未確認のことは「未確認」の節にまとめ、確認済みの事実と混ぜない。
- 古くなった notes は削除するか、`Date` の下に `- Outdated: [理由]` を足して状態を明示する。
- 秘密情報、認証情報、private config を書かない。

## 実体を写さない

skill や設定の内容を notes へ列挙すると、片方を直した時にもう片方が古くなる。**列挙は実体を正本とし、notes には「なぜその形か」だけを書く。**

実体を指す時は、正本の場所を書く。

```markdown
Gotchas に入れたのは、この環境で実際に踏んだもの。列挙は `skills/git-commit/SKILL.md` を正本とし、ここでは繰り返さない。
```
