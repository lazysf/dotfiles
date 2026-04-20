# 知見の昇格ルール

この文書は、ハーネス運用で得た知見を `docs / skills / rules / agents / config` のどこへ反映するかを、展開後にも参照できる形で短く固定したものです。

## いつ docs に書くか

- 展開後にも読者が参照する判断基準、構成、接続方法、検証手順である
- 実行順序や期待結果を文章で案内する方が自然である
- project-specific knowledge ではなく、どの workspace にも共通する話である

## いつ skill にするか

- 同じ整理手順や判断フローを何度も繰り返す
- main conversation の文脈で実行したい
- 機械的な禁止や許可ではなく、再利用可能な進め方として残したい

## いつ rule / config / agent に落とすか

- `rules`: 破壊的操作、広域操作、外部接続などを機械的に止めたい
- `private_config.toml.tmpl`: 共通既定値として常に有効にしたい
- `agents`: read-only で専門化した探索やレビューを繰り返す

## 停止線

- repo-level の保守知識や調査メモは保守元 repo 側の文書に置き、`~/.codex/` へ持ち込まない
- project-specific knowledge は各 project の `docs/` を正本とし、共通ハーネスへ混ぜない
- 将来使うかもしれないだけの抽象化は昇格しない
