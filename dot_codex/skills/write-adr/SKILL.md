---
name: write-adr
description: 「この判断を ADR として残したい」「新しい ADR を追加したい」といった依頼で使う。背景、決定、影響を `docs/adr/NNNN-kebab-case-title.md` として採番し、`Proposed` 状態の新規 ADR を作成する。既存 ADR の状態を更新したい時は `update-adr-status` スキル、通常知見メモを書きたい時は `write-knowledge-note` スキルを使う。
metadata:
  short-description: ADR 作成
---

# Write ADR

判断記録として残す内容を、`root docs/adr/` 向けの新規 ADR として作成する。
この skill は採番、path 決定、本文生成、新規ファイル作成、`docs/README.md` へのリンク追加に責務を限定し、既存 ADR の状態更新は行わない。

## 基本方針

- ADR として残す理由を先に明確にする。
- 通常の知見メモではなく、判断記録として残す内容だけを扱う。
- 新規 ADR は常に `Proposed` で作成する。
- 新 ADR が旧 ADR を置き換える場合は、新 ADR 側にだけ `Supersedes` を書き、後段での自動補完は前提にしない。
- `Accepted` 化は project policy に従って `git-commit` / `git-push` と `update-adr-status` で行う。
- `Supersedes` を含む場合は、受理後の後段導線で旧 ADR を別更新して `Superseded` に進める。
- 代替案は長文化せず、判断理由に必要な範囲だけを書く。

## 対象

- 複数案から 1 つを選んだ理由を残したい判断
- 方針変更や互換性判断
- 採用 / 不採用の決定を後から参照したい内容

## 対象外

- 一般的な知見メモ
- 手順メモ
- 再発防止メモだけで足りる内容
- 既存 ADR の `Status` や `Superseded-By` の更新

## 出力ガイド

- 結果は `status=created|skipped`、`path`、`adr_number`、`title`、`reason` を返せる形にする。
- path は `docs/adr/NNNN-kebab-case-title.md` の形式で、既存番号の最大値 + 1 を使って決める。
- ADR 本文には少なくとも次を含める。
  - `# Title`
  - `- Status: Proposed`
  - 必要なら `- Supersedes: 0003`
  - `## Context`
  - `## Decision`
  - `## Consequences`

## 手順

### 1) 判断記録として残す理由を整理する

- 何を決めたのかを一文でまとめる。
- なぜ通常の知見ではなく ADR にするのかを確認する。

### 2) 判断材料をそろえる

- 背景、制約、選んだ案を整理する。
- 却下した代替案があれば、必要最小限で要点だけ残す。
- 置き換える旧 ADR がある場合だけ、その番号を明示 `Supersedes` として受け取る。

### 3) ファイル名案を作る

- 内容を表す短い kebab-case のタイトルを付ける。
- 既存 ADR 番号の最大値 + 1 を次番号にする。
- path は `docs/adr/NNNN-kebab-case-title.md` として決める。

### 4) ADR 本文を書く

- `Context` に背景と判断が必要になった理由を書く。
- `Decision` に採用した内容を明記する。
- `Consequences` に影響、トレードオフ、今後の前提を短く書く。
- メタ行は `- Status: Proposed` を必須にし、必要なら `- Supersedes:` を追加する。

### 5) 新規ファイルを作成する

- 決めた path に新規 ADR を作成する。
- 既存ファイルの上書きは行わない。

### 6) `docs/README.md` にリンクを追加する

- `docs/adr/` の一覧に新しい ADR へのリンクを 1 件追加する。
- 状態注記や履歴注記は README に書かない。

## 完了条件

- ADR として残す理由が説明できる
- `docs/adr/NNNN-kebab-case-title.md` 形式の path と番号がある
- `Status / Context / Decision / Consequences` を含む本文がある
- 新規 ADR と README リンクが作成されるか、`skipped` 理由が説明できる
