# Request Format

`request.md` はユーザーの元要求・要望を保持する。要件化は `requirements.md` に任せる。

## Rules

- ユーザーの元要求・要望は可能なら原文に近く残す。ただし secret 値、credential、private config value、未公開個人情報は原文保存せず、`[REDACTED: 種類 / 用途]` の形で残す。
- 背景、期待状態、不明点を分ける。
- 要求・要望の再定義履歴だけ `RQ-REV-*` を使う。
- 推測を事実として書かない。

## Template

```markdown
# Request

## 元の要求・要望

[ユーザーが最初に入力した要求・要望。可能なら原文に近く残す。ただし secret 値、credential、private config value、未公開個人情報は redacted で残す。]

## 背景

[会話で確認した背景。未確認の推測は書かない。]

## 期待状態

[ユーザーが最終的に期待している状態。]

## 不明点

- [Phase 1 で確認すべき不明点。]

## 再定義履歴

### RQ-REV-001

- 理由: [目的理解、成功条件、前提が大きく変わった理由。]
- 変更前: [以前の要求・要望の要点。]
- 変更後: [再定義後の要求・要望の要点。]
```
