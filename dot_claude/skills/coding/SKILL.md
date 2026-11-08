---
name: coding
description: ソースファイルを書く・直す時に、言語固有の形式に当たる場面と、コードにコメントを書く場面で使う。既存ファイルの charset / 改行 / BOM、識別子の上限と使える文字、toolchain が要求する metadata、VBA（`.bas` / `.cls`）の形式、意図的な簡略化で残した既知の上限を `tradeoff:` コメントで残す規約を扱う。ユーザーが形式やコメントという語を出さなくても、ソースを新規作成・編集するなら対象。doc の作成・更新は `scribe`、変更の見直しは `lapidary`。
---

# Coding

## 言語固有の形式と制約

charset、改行、BOM、必須の metadata、識別子の上限は、守らないとファイルが読み込めなくなる。可読性の判断より前に来る。書く前に確認する。

- 既存ファイルの charset / 改行 / BOM。明確な既存形式があれば、既定より既存を優先する。 一貫性が崩れると diff がファイル全体に広がる。
- 識別子の上限と使える文字。言語仕様で確かめる。記憶で書くと、長い名前がコンパイル時まで気づかれない。
- toolchain が要求する metadata。import や build が読む行で、消すとファイルの identity が失われる。

該当する言語の reference があれば読む。

- VBA（`.bas` / `.cls`）: [references/vba.md](references/vba.md)

reference が無い言語は、上の 3 点を言語仕様で確認してから書く。

## コメント

- 意図的に簡略化して既知の上限を残した箇所は `tradeoff:` で始め、上限と作り直す条件を書く。条件が無いと、後から読んだ人が今も妥当か判断できない。例: `# tradeoff: 全体 lock。throughput が問題になったら口座ごとの lock へ`
- security に関わる上限は `tradeoff:` で閉じない。停止線に当たるので、コメントに残さずユーザーへ確認する。
