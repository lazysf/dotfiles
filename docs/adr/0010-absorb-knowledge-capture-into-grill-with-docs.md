# 0010: 知見蓄積入口を `grill-with-docs` へ吸収する

- Status: Accepted

`grill-with-docs` は plan / design を既存 docs、ADR、code、context language と照合しながら問い詰め、確定した用語や判断を inline で残す workflow として採用する。独立した知見蓄積 skill を残すと、docs-aware grilling と durable knowledge の反映境界が二重化するため、CONTEXT / ADR 形式知を `grill-with-docs` の references に移し、知見蓄積の user-facing 入口を統合する。
