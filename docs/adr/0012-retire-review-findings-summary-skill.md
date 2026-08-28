# 0012: review findings summary skill を退役する

- Status: Accepted
- Amended-By: 0013, 0016, 0017
- Amends: 0011

reviewer agent の出力を別 skill で整形すると、review surface が増え、固定 JSON 前提も残りやすい。review 本体は reviewer agent に維持し、結果は agent 自身が人間向けに読みやすく返す方針へ寄せる。そのため `review-findings-summary` skill は退役し、正式 surface は prefix なし skill と reviewer agent に寄せる。
