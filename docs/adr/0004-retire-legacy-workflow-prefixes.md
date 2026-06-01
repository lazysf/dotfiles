# 0004: legacy workflow skill prefix を廃止する

- Status: Accepted
- Supersedes: 0003

## Context

共通ハーネスの skill surface には、実行手順として使う `core-*` と、旧導線互換のために残した `entry-classify` / `phase-*` が混在していた。
この構成は移行期の橋渡しとしては有効だったが、現行の導線説明、skill 選択、検証のすべてで prefix の意味を読み解く負担を残していた。

現在の運用では、主目的に近い skill をそのまま選ぶ導線が定着しており、prefix と wrapper を残す価値よりも、surface を単純に保つ価値の方が大きい。

## Decision

- 公開する workflow skill 名は prefix なしの kebab-case に統一する
- 旧 `core-*` は bare 名へ改名し、ディレクトリ名、frontmatter `name:`, 見出し、本文参照も同じ名前にそろえる
- `entry-classify` と `phase-*` は互換 alias を残さず廃止する
- 旧 prefix ベースの名称は履歴として `docs/adr/` にのみ残し、現行 docs や skill surface には持ち込まない
- 検証スクリプトで旧 prefix や wrapper surface の再混入を失敗扱いにする

## Consequences

- `dot_codex/skills/` は prefix なし skill だけを置く単純な surface になる
- `dot_codex/AGENTS.md` と `docs/notes/` は、prefix の意味を説明せずに現行導線だけを案内できる
- 旧名称への互換性は提供しないため、過去の呼び方に依存する導線は更新が必要になる
- 将来 skill を追加するときも、役割の区別は prefix ではなく prose と配置で表現する前提になる
