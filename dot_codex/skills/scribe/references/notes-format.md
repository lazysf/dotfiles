# notes 形式

`docs/notes/` に置く軽量メモ。背景、調査結果、運用 tip、後で参照したい一次情報を残す。
仕様、判断記録、scratchpad、秘密情報の置き場ではない。

## 使う場面

- 仕様 doc に書くほどではないが、third-party / 将来の自分が再調査するコストを下げたい背景や調査結果。
- ADR の 3 条件を満たさない判断や、補足の文脈メモ。
- 外部リソース、参照したコマンド結果、benchmark のサマリ。

## ルール

- 1 ファイル 1 話題。タイトルは内容を短く表す kebab-case。
- 推測でなく確認した事実を書く。出典（URL、command、ファイル path、commit）を添える。
- 公開 IF、API、設定の正規仕様は notes に書かず、README / docs に書く。
- 判断記録（複数案を比較した結果）は notes ではなく ADR に書く。
- 古くなった notes は削除するか、`Outdated:` の 1 行で状態を明示する。
- 秘密情報、認証情報、private config を書かない。

## 最小テンプレート

```markdown
# [タイトル]

- Date: YYYY-MM-DD
- 出典: [URL / command / file path / commit hash]

[本文。事実、調査経緯、参照したい snippet。]
```

## 置き場

- `docs/notes/` 直下にフラットに置く。粒度が増えたら subdirectory で group 化する。
- `docs/README.md` がある場合、必要なら notes の代表 entry を一覧に追加する（全件は不要）。
