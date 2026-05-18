# 0012: review findings summary skill を退役する

- Status: Accepted
- Amends: 0011
- Amended by: 0013

reviewer agent の出力を別 skill で整形すると、review surface が増え、固定 JSON 前提も残りやすい。review 本体は 4 つの reviewer agent に維持し、結果は agent 自身が人間向けに読みやすく返す方針へ寄せる。そのため `review-findings-summary` skill は退役し、正式 surface は 12 個の skill と 4 個の reviewer agent とする。
