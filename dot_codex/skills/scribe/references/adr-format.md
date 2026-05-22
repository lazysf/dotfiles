# ADR 形式

ADR は `docs/adr/` に置き、`0001-slug.md`、`0002-slug.md` のように連番を使う。
軽量な ADR 本文と必須の `Status` を使う。

## ADR を作る条件

次の 3 条件をすべて満たす場合だけ ADR を作る。

1. 戻しにくい: あとで方向転換する cost が意味を持つ。
2. 文脈なしでは意外: 将来の読み手が、なぜこの道を選んだのか疑問に思う。
3. 実際の trade-off: 実在する代替案があり、特定の理由で 1 つを選んだ。

戻しやすい、明らか、実質的な代替案がない判断では ADR を作らない。責務外の内容は書かない。

## 最小テンプレート

```markdown
# NNNN: [短い決定タイトル]

- Status: Proposed

[背景、決定、理由を 1-3 文で説明する。]
```

## 状態

`Status` は必須。使える値:

- `Proposed`: 作成済みだが、まだ採用されていない
- `Accepted`: 採用され、現在も有効
- `Superseded`: 後続 ADR に置き換えられた
- `Rejected`: 不採用案として残す

relationship metadata は明示的に分かっている場合だけ使う:

- `- Supersedes: 0003`
- `- Superseded-By: 0005`
- `- Amends: 0003`
- `- Amended by: 0005`

relationship metadata を推測で補わない。`Supersedes` は置換、`Amends` は有効な ADR の一部修正・拡張だけに使う。

## 任意セクション

実際に価値がある場合だけ section を追加する。

```markdown
## 背景

[決定が必要になった確認済み背景。]

## 決定

[選んだ方向。]

## 影響

[自明ではない影響、制約、残リスク。]
```

検討 options など他の任意 section は、不採用案を残す価値がある場合だけ使う。

## 採番

- `docs/adr/` を確認し、既存の最大番号を探す。
- 番号を 1 つ増やす。
- 短い kebab-case slug を使う。
- `docs/README.md` が存在する場合は、新しい ADR を一覧へ追加する。

## ライフサイクル更新

- 新しい ADR は `Proposed` から始める。
- ユーザーが採用を明示した場合だけ `Accepted` にする。
- ユーザーが不採用を明示した場合だけ `Rejected` にする。
- 新しい ADR が `Supersedes` に古い ADR を明示している場合だけ、古い ADR を `Superseded` にする。
- 新しい ADR が `Amends` に古い ADR を明示している場合だけ、古い ADR に `Amended by` を追加する。
- `Supersedes` や `Superseded-By` を推測で backfill しない。
