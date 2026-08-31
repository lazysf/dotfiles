# markdownlint / pre-commit の実行経路

- Date: 2026-08-31
- 出典: `.pre-commit-config.yaml` / `.markdownlint-cli2.jsonc` / `package.json` / `.git/hooks/pre-commit` / `node_modules/markdownlint-cli2/markdownlint-cli2.mjs` / `~/.cache/prek/repos/*/.pre-commit-hooks.yaml` / `prek --version` / 使い捨て repo での `git commit` 実測 / markdownlint 0.40.0 の API による rule 単体実測 / `node_modules/markdownlint/doc/md024.md` / commit `287cc7b` `be928f2`

Markdown lint は「手で走らせる経路」と「commit 時に走る経路」の 2 本があり、同じ設定ファイルを読むが別の binary を実行する。設定を触る前にどちらが動くかを取り違えないための記録。

hook の一覧と設定値は `.pre-commit-config.yaml` と `.markdownlint-cli2.jsonc` を正本とし、ここでは繰り返さない。

## 2 本の経路

| 経路 | 起動 | 実行される binary |
| --- | --- | --- |
| 手動 | `npm run lint` / `npm run lint:fix` | repo の `node_modules/markdownlint-cli2` |
| commit 時 | `git commit` → `.git/hooks/pre-commit` | prek が cache に用意した hook 環境の `markdownlint-cli2` |

同じ `.markdownlint-cli2.jsonc` を読み、2026-08-31 時点はどちらも 0.22.1 なので判定は揃う。version を上げる時は `package.json` の dependency と `.pre-commit-config.yaml` の `rev` の両方を動かさないと、この 2 経路がずれる。

## runner は pre-commit ではなく prek

`.git/hooks/pre-commit` は prek（`/opt/homebrew/bin/prek`、2026-08-31 時点 0.5.0）が生成したもので、`prek hook-impl` へ委譲する。Python の `pre-commit` は install されていない。prek は `.pre-commit-config.yaml` 互換なので設定ファイル側に prek 固有の記述はなく、hook を追加する時も pre-commit の書式で書く。

hook の実行環境（Node / Python）は prek が `~/.cache/prek/` 配下へ自前で用意する。repo の `node_modules` や `.venv` は使わない。sandbox で `~/.cache/prek/` への write を許可しているのはこのため（[claude-code-settings-design.md](./claude-code-settings-design.md)）。

## staged 分だけでなく repo 全体が lint される

`markdownlint-cli2` は設定の `globs` を **コマンドライン引数へ追加する**（置換しない。`markdownlint-cli2.mjs` の `appendToArray(globPatterns, globs)`）。hook は staged file を引数で渡すが、設定に `**/*.md` があるため、実際の対象は毎回 repo 全体の Markdown になる。

```console
$ npx markdownlint-cli2 README.md
Finding: README.md **/*.md !node_modules/** !.venv/** !.cache/** !.git/**
Linting: 70 file(s)
```

hook 自体が発火するのは staged に `.md` がある時だけ（hook 定義の `types: [markdown]`）。だが一度発火すると、staged していない Markdown の違反でも commit は止まる。使い捨て repo で `git commit` を実測した結果は次の 2 通りだった。

- **対象 file に unstaged 変更が無い場合**: `--fix` が適用され、commit は `files were modified by this hook` で失敗する。修正内容は unstaged の変更として working tree に残る（`Summary: 0 error(s)` でも失敗する）。
- **対象 file に unstaged 変更がある場合**: prek は hook 実行前に unstaged 分を patch へ退避する。hook の修正がその patch と衝突すると `Hook changes conflicted with the saved unstaged changes. Reverting the hook changes` となり、hook の修正は捨てられて退避分が戻る。この時は手で直すしかない。

どちらも「今の commit と無関係な file が原因で止まる」ので、失敗時はまず対象 file 名を見る。書き換える hook の一覧と失敗時の扱いは [git-commit-skill-design.md](./git-commit-skill-design.md) にある。

## MD013 / MD024 を無効化している理由

どちらも commit message に理由の記載がないので、rule を単体で有効にした時の違反数を実測した（`{ "default": false, "<rule>": true }` を markdownlint の API へ渡す。設定ファイルの `config` は `--config` より優先されるため、CLI からは上書きできない）。

- **`MD013`（line-length、既定 80）**: `287cc7b`（2026-04-21）で無効化。markdownlint-cli2 導入より前で、当時から理由の記載はない。現在の tree で有効に戻すと 70 file 中 62 file・460 件。この repo の Markdown は日本語の段落を 1 行で書き hard wrap しないので、rule 自体が書き方と噛み合わない。
- **`MD024`（no-duplicate-heading）**: `be928f2` で markdownlint-cli2 導入と同時に無効化。その時点の tree で有効にすると 164 件 / 8 file 出て、全て `docs/requests/**/test.md` の繰り返し見出し（「対応」「種別」「手順」）だった。この artifact 群は [ADR 0039](../adr/0039-retire-docs-requests-artifacts.md) で削除済みで、現在の tree では有効にしても 0 件で、無効化の原因は消えている。
  それでも無効のまま維持する。MD024 の目的は同名見出しから同じ anchor が生成される事故を防ぐことだが（`markdownlint` の `doc/md024.md`）、この repo の `.md` に anchor link（`](#...)`）は 0 件で、防ぐ対象が無い。MD024 は自動修正を持たないため、既定の `siblings_only: false` では将来 changelog 型の繰り返し見出しを書いた時に commit が止まり、手で直すことになる。anchor link を使い始めたら、既定ではなく `"MD024": { "siblings_only": true }` で入れ直す。

## 未確認

- `check-toml` / `check-yaml` は登録されていない。repo に `.tombi.toml` や `nvim.yml` があるので対象は存在するが、意図的に外したのか未検討なのかは不明。
