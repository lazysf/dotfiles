# Architecture 用語

architecture 改善候補を扱う時は、次の用語を優先する。

## 用語

**Module**: interface と implementation を持つ単位。function、package、feature slice などを含む。
_Avoid_: component, service, unit

**Interface**: caller が module を正しく使うために知る必要があるもの。型、invariant、順序、error mode、config、性能期待を含む。
_Avoid_: API, signature

**Implementation**: module の interface の背後に隠れる code と behavior。

**Depth**: module が interface を通じて提供する leverage。深い module は、小さく安定した interface の背後に十分な behavior を隠す。
_Avoid_: line-count ratio

**Shallow module**: interface が、それによって隠す implementation と同じくらい複雑な module。

**Seam**: caller を直接編集せず、interface を通じて behavior を差し替えられる場所。
_Avoid_: boundary

**Adapter**: seam にある interface を満たす具体 implementation。

**Locality**: 変更、bug、検証が caller 群に広がらず、どれだけ 1 箇所に集まるか。

**Leverage**: 1 つの interface が有用な behavior への入口を提供し、caller が知識を繰り返さずに済む効果。

## 原則

- depth は implementation の行数ではなく、interface に宿る。
- interface を主な test surface として扱う。
- adapter が 1 つだけなら仮説上の seam であることが多く、2 つあるなら seam が役割を持っていることが多い。
- module を削除して同じ複雑さが caller に移るだけなら、その module は有用だった可能性が高い。削除して複雑さも消えるなら、pass-through だった可能性がある。
