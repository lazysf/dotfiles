# PRD Format

`docs/PRD.md` を作成・更新する時に使う。
project または product change 全体の要求を置く。個別 feature の詳細要件は `docs/REQUIREMENTS.md` に寄せる。

## Rules

- PRD 用フォルダは作らず、`docs/PRD.md` を使う。
- 確認済み事実と未確認事項を混ぜない。
- 未確認事項は `Open Questions` に残す。
- 秘密情報、認証情報、private config、未公開個人情報を入れない。

## Template

```markdown
# PRD

## Overview

[何を実現したいか。1-3 文。]

## Problem

[ユーザーに見える問題、workflow の痛み、または機会。]

## Goals

- [観測可能な目的。]

## Success Criteria

- [満たされたと判断できる結果。]

## Scope

- [含めること。]

## Non-goals

- [意図的に扱わないこと。]

## Users / Actors

- [対象利用者または関係者。]

## Requirements Summary

- `FR-001`: [feature / requirement の短い説明。]

## Constraints

- [互換性、運用、policy、UX、data、rollout などの制約。]

## Open Questions

- [未確認事項。]
```
