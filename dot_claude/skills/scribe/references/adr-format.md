# ADR 形式

ADR を書く時に読む。「ADR を作る条件」と「既存 ADR の扱い」は `../SKILL.md` を正本にする。形の元は [Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) と [MADR](https://adr.github.io/madr/)。

## 置き場と命名

`docs/adr/` に `NNNN-slug.md` の形で置く。slug は決定内容を短く表す kebab-case。採番は `ls docs/adr/` で最大番号を確認してから決め、番号は飛ばさず、既存の番号を再利用しない。

## 構成

次の 4 つの節を必ず書く。各節は 1〜2 文でよい。全体は 1〜2 ページに収める。

```markdown
# NNNN: [決定を表す短い題]

- Date: YYYY-MM-DD
- Status: Proposed

## 背景

[決定が必要になった、確認済みの事情。]

## 決定

[選んだ方向。]

## 検討した代替案

- [案]: [捨てた理由。]

## 影響

[良い影響、悪い影響、制約、残るリスク。]
```

- 検討した代替案: 実際に比べた案を、案ごとに捨てた理由と一緒に書く。この節が書けない判断は、「ADR を作る条件」の 1 と 3 を満たしていない。
- 影響: 良い影響だけでなく、悪い影響と制約も書く。後の読み手が判断を見直す時、悪い影響がいちばん要る。
- 題は、何を決めたかが分かる形にする。「〜について」のような題にしない。

## Date と Status

`Date` は ADR を作った日。`Status` を変えても書き換えない。`Date` を持たない既存の ADR に、後から足さない（`../SKILL.md` の「既存 ADR の扱い」）。

`Status` は必須。値は次の 4 つ。

| 値 | 意味 |
| --- | --- |
| `Proposed` | 作成済みだが、まだ採用されていない |
| `Accepted` | 採用され、現在も有効 |
| `Superseded` | 後続 ADR に置き換えられた |
| `Rejected` | 不採用案として残す |

`Accepted` と `Rejected` は、ユーザーの明示依頼か会話上の合意がある時だけ付ける。commit や push の有無で自動的に進めない。

`Deprecated`（置き換え先の無い退役）は使わない。退役は、理由を書いた新しい ADR で置き換えて表す（「更新と退役」）。本文を書き換えられないので、退役の理由を残す先は新しい ADR しか無い。

## 関係メタデータ

`Status` の直後に、分かっているものだけ書く。

```markdown
- Date: 2026-01-15
- Status: Superseded
- Superseded-By: 0042
- Supersedes: 0003
```

| キー | 使う場面 |
| --- | --- |
| `Supersedes: NNNN` | この ADR が旧 ADR を置き換えた |
| `Superseded-By: NNNN` | この ADR が後続に置き換えられた |
| `Amends: NNNN` | 有効な ADR の一部を補正・拡張した（置き換えではない） |
| `Amended-By: NNNN` | 後続に一部を補正・拡張された |

順序は `Date` → `Status` → `Superseded-By` → `Supersedes` → `Amended-By` → `Amends`。置き換えは補正より強い関係なので先に、各対では自分が受けたものを先にする。1 つのキーが複数の番号を持つ時はカンマ区切りで番号順に並べる（`Supersedes: 0001, 0004, 0006`）。

トークン内の空白は `-` にする（git trailer 仕様）。`Amended by` のようにスペースを入れない。

## 更新と退役

採用した ADR の本文は書き換えない。直してよい範囲は `../SKILL.md` の「既存 ADR の扱い」に従う。

### 複数の ADR をまとめて退役させる

前提を失った ADR が複数ある時は、1 枚の新 ADR にまとめる。

1. 新 ADR の `Supersedes` に対象の番号を昇順で列挙する。
2. `## 影響` に、各 ADR が何を失ったかを 1 行ずつ書く。対象が消えたのか、判断が覆されたのかを区別する。
3. 退役させる ADR に今も生きている原則が含まれるなら、継承する旨を同じ節に書く。書かないと ADR ごと原則が消える。
4. 旧 ADR 側に `Status: Superseded` と `Superseded-By: NNNN` を足す。既存の関係メタデータは消さない。

同じ理由で退役しない ADR が混ざる時は、維持する側も列挙して理由を書く。読み手が「なぜこれは残ったか」を追えるようにする。
