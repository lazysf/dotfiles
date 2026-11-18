# CHANGELOG 形式

`CHANGELOG.md` を作成・更新する時に読む。作る条件（版を出す repo）は `../SKILL.md` の「置き場の選び方」の表を正本にする。

## 置き場と命名

既定の置き場は repo root の `CHANGELOG.md`。形式は [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) に従う。既存の CHANGELOG が別の形式なら、その形式に従う。

## 構成

```markdown
# Changelog

## [Unreleased]

### Changed

- **Breaking:** [利用者から見た変化。] [直し方。]

## [1.2.0] - YYYY-MM-DD

### Added

- [利用者から見た変化。]

[Unreleased]: [前の版から HEAD までの比較 URL]
[1.2.0]: [その前の版から 1.2.0 までの比較 URL]
```

- 新しい版を上に置く。日付は YYYY-MM-DD。
- 版の中の節は、Keep a Changelog の 6 つ（`Added`、`Changed`、`Deprecated`、`Removed`、`Fixed`、`Security`）だけを使う。項目の無い節は作らない。
- 末尾の比較リンクは、既存の CHANGELOG が持っていれば保つ。

## 書く規則

- 利用者に見える変更だけを書く。読み手は、版を上げるかどうかを決める利用者。
- commit log を写さない。内部のリファクタリング、試験、CI、doc の修正は、利用者の挙動を変えない限り書かない。
- 1 項目には、利用者から見た変化を書く。変えたファイルや関数の名前ではなく、使い方や挙動がどう変わったかを書く。
- 廃止を予告したものは `Deprecated` に、消したものは `Removed` に置く。
- 破壊的変更は、項目の先頭に `**Breaking:**` を付ける（[Common Changelog](https://common-changelog.org/)）。既存の CHANGELOG に別の印があれば、それに従う。
- 破壊的変更、廃止、削除には、利用者の直し方を添える。
- `Security` の項目には、修正を出す前に、悪用につながる詳細を書かない。

## 更新と退役

- 版の番号と日付は推測しない。決まっていない間は `[Unreleased]` に足す。
- repo が [SemVer](https://semver.org/spec/v2.0.0.html) に従うと書いていれば、項目から上げる桁の案を示して、ユーザーに聞く。`**Breaking:**` があれば major、`Added` か `Deprecated` があれば minor、`Fixed` だけなら patch。
- 版を出す時に、`[Unreleased]` の項目を新しい版の節へ移す。版の番号はユーザーに聞く。repo の定義（`package.json` の version、tag）がすでに新しい版を指していれば、それに揃える。
- 版を足したら、末尾の比較リンクを直す。`[Unreleased]` の起点を新しい版にし、新しい版の行を足す。
- 出した版の節は、誤りの修正を除いて書き換えない。利用者は、出た時の記述を頼りに版を選んでいる。
- 取り下げた版は、見出しの末尾に `[YANKED]` を付ける。
