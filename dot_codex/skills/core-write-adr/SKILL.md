---
name: core-write-adr
description: Capture Knowledge フェーズの内部 writer 手順。architecture decision record、設計判断、運用判断、互換性判断、採用 / 不採用の決定を `root docs/adr/` 向けの番号付き標準形 Markdown 草案へ整理する。
metadata:
  short-description: ADR 草案作成
---

# Write ADR

判断記録として残す内容を、`root docs/adr/` 向けの ADR 草案へ整理する。
この skill は文面作成に責務を限定し、採番実行やファイル作成は行わない。
フェーズ全体の入口は `phase-capture-knowledge` を参照する。

## 基本方針

- ADR として残す理由を先に明確にする。
- 通常の知見メモではなく、判断記録として残す内容だけを扱う。
- 草案は後から参照しやすい最小構成に絞る。
- 代替案は長文化せず、判断理由に必要な範囲だけを書く。

## 対象

- 複数案から 1 つを選んだ理由を残したい判断
- 方針変更や互換性判断
- 採用 / 不採用の決定を後から参照したい内容

## 対象外

- 一般的な知見メモ
- 手順メモ
- 再発防止メモだけで足りる内容

## 出力ガイド

- 想定ファイル名案は `docs/adr/NNNN-kebab-case-title.md` の形式で示す。
- `NNNN` はプレースホルダとして扱い、実際の採番は行わない。
- ADR 本文草案には少なくとも次を含める。
  - `# Title`
  - `- Status: Proposed`
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

### 3) ファイル名案を作る

- 内容を表す短い kebab-case のタイトルを付ける。
- ファイル名案は `docs/adr/NNNN-kebab-case-title.md` として返す。

### 4) ADR 草案を書く

- `Context` に背景と判断が必要になった理由を書く。
- `Decision` に採用した内容を明記する。
- `Consequences` に影響、トレードオフ、今後の前提を短く書く。

## 完了条件

- ADR として残す理由が説明できる
- `docs/adr/NNNN-kebab-case-title.md` 形式のファイル名案がある
- `Status / Context / Decision / Consequences` を含む草案がある
