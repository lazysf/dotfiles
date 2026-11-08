# markdownlint / pre-commit の実行経路

- Date: 2026-11-08
- 出典: `prek.toml` / [prek Configuration](https://prek.j178.dev/configuration/) / [tombi-toml/tombi-pre-commit](https://github.com/tombi-toml/tombi-pre-commit) / `node_modules/.bin/tombi --help` / `.markdownlint-cli2.jsonc` / `package.json` / `.git/hooks/pre-commit` / `node_modules/markdownlint-cli2/markdownlint-cli2.mjs` / `~/.cache/prek/repos/*/.pre-commit-hooks.yaml` / `prek --version` / 使い捨て repo での `git commit` 実測 / markdownlint 0.40.0 の API による rule 単体実測 / `node_modules/markdownlint/doc/md024.md` / commit `287cc7b` `be928f2`

Markdown（markdownlint）と TOML（tombi）の lint は、それぞれ「手で走らせる経路」と「commit 時に走る経路」の 2 本ある。同じ設定ファイルを読むが、実行する binary は別。設定を触る前にどちらが動くかを取り違えないための記録。

hook の一覧と設定値は `prek.toml` と `.markdownlint-cli2.jsonc` を正本とし、ここでは繰り返さない。

## 2 本の経路

| 経路 | 起動 | 実行される binary |
| --- | --- | --- |
| 手動 | `npm run lint` / `npm run lint:fix` | repo の `node_modules/markdownlint-cli2` |
| commit 時 | `git commit` → `.git/hooks/pre-commit` | prek が cache に用意した hook 環境の `markdownlint-cli2` |

同じ `.markdownlint-cli2.jsonc` を読み、2026-11-08 時点はどちらも 0.24.0 なので判定は揃う。version を上げる時は `package.json` の dependency と `prek.toml` の `rev` の両方を動かさないと、この 2 経路がずれる。

## TOML の tombi も同じ 2 本

| 経路 | 起動 | 実行される binary |
| --- | --- | --- |
| 手動 | `npm run lint:toml` / `npm run lint:toml:fix` | repo の `node_modules/tombi` |
| commit 時 | `git commit` → `.git/hooks/pre-commit` | prek が `tombi-toml/tombi-pre-commit` から用意した hook 環境の `tombi` |

どちらも `.tombi.toml` を読む。VS Code の tombi 拡張も同梱の tombi で判定する。2026-11-08 時点で 3 つとも 1.10.0。version を上げる時は、`package.json`、`prek.toml` の `rev`、VS Code 拡張の 3 つを揃える。

hook は `uv.lock` を対象から外している。prek は `uv.lock` を `toml` と判定するので、外さないと tombi-format が uv の生成物を書き換える（2026-11-08 に `--all-files` で発生）。手動の経路は `.tombi.toml` の `**/*.toml` だけを見るので、外すと 2 経路の対象が揃う。

`tombi format --diff` は差分を表示するだけでなく、ファイルを書き換える（1.10.0、2026-11-08）。差分だけ見たい時は `--check` を使う。

## runner は pre-commit ではなく prek

`.git/hooks/pre-commit` は prek（`/opt/homebrew/bin/prek`、2026-11-08 時点 0.5.10）が生成したもので、`prek hook-impl` へ委譲する。hook は設定ファイルの名前を持たず、prek が実行時に探す。Python の `pre-commit` は install されていない。

設定は prek 独自の `prek.toml` に置く。Python の `pre-commit` を使わないので、`.pre-commit-config.yaml` で互換を保つ利点が無い。hook は配列テーブル（`[[repos.hooks]]`）で書く。`prek util yaml-to-toml` の出力は複数行のインラインテーブルを使うが、tombi の format はこれを 1 行に詰め、hook の一覧が読めなくなる（tombi 1.10.0、2026-11-08）。配列テーブルなら tombi の format を通っても形が変わらない。`.pre-commit-config.yaml` を置き直さない。prek は同じ directory に両方あると `prek.toml` を優先し、どちらが効いているか分かりにくくなる。

`prek.toml` は `.` で始まらないので、`.chezmoiignore` に載せないと home へ配布される。

hook の `rev` は commit SHA でなく tag で固定している（2026-11-08 のユーザー判断）。tag は付け替えられるので、厳密な固定ではない。付け替えた後に cache の無い状態で commit すると、別の code が走る。cache の無い状態は、新しい作業機の立ち上げ、cache の削除、`rev` の更新で生じる。人が terminal から commit すると、その code は sandbox の外で人の権限で走る。それでも tag にしているのは、3 つの hook repo がどれも各 tool の公式のもので、`rev` を上げる時に版が読めるため。hook repo に lockfile は無く、hook 環境の推移的な依存は install の時点の semver の範囲で決まる。SHA で固定しても、この揺れは残る。固定を見直すなら、SHA にして tag を行末のコメントに残す形にする。

hook の実行環境（Node / Python）は prek が `~/.cache/prek/` 配下へ自前で用意する。repo の `node_modules` や `.venv` は使わない。sandbox で `~/.cache/prek/` への write を許可しているのはこのため（[claude-code-settings-design.md](./claude-code-settings-design.md)）。

## staged 分だけでなく repo 全体が lint される

`markdownlint-cli2` は設定の `globs` を **コマンドライン引数へ追加する**（置換しない。`markdownlint-cli2.mjs` の `appendToArray(globPatterns, globs)`）。hook は staged file を引数で渡すが、設定に `**/*.md` があるため、実際の対象は毎回 repo 全体の Markdown になる。

```console
$ npx markdownlint-cli2 README.md
Finding: README.md **/*.md !node_modules/** !.venv/** !.cache/** !.git/**
```

hook 自体が発火するのは staged に `.md` がある時だけ（hook 定義の `types: [markdown]`）。だが一度発火すると、staged していない Markdown の違反でも commit は止まる。使い捨て repo で `git commit` を実測した結果は次の 2 通りだった。

- **対象 file に unstaged 変更が無い場合**: `--fix` が適用され、commit は `files were modified by this hook` で失敗する。修正内容は unstaged の変更として working tree に残る（`Summary: 0 error(s)` でも失敗する）。
- **対象 file に unstaged 変更がある場合**: prek は hook 実行前に unstaged 分を patch へ退避する。hook の修正がその patch と衝突すると `Hook changes conflicted with the saved unstaged changes. Reverting the hook changes` となり、hook の修正は捨てられて退避分が戻る。この時は手で直すしかない。

どちらも「今の commit と無関係な file が原因で止まる」ので、失敗時はまず対象 file 名を見る。書き換える hook の一覧と失敗時の扱いは [git-commit-skill-design.md](./git-commit-skill-design.md) にある。

## MD013 / MD024 を無効化している理由

どちらも commit message に理由の記載がないので、rule を単体で有効にした時の違反数を実測した（`{ "default": false, "<rule>": true }` を markdownlint の API へ渡す。設定ファイルの `config` は `--config` より優先されるため、CLI からは上書きできない）。

- **`MD013`（line-length、既定 80）**: `287cc7b`（2026-04-21）で無効化。markdownlint-cli2 導入より前で、当時から理由の記載はない。2026-08-31 時点の tree で有効に戻すと 460 件。この repo の Markdown は日本語の段落を 1 行で書き hard wrap しないので、rule 自体が書き方と噛み合わない。
- **`MD024`（no-duplicate-heading）**: `be928f2` で markdownlint-cli2 導入と同時に無効化。その時点の tree で有効にすると 164 件 / 8 file 出て、全て `docs/requests/**/test.md` の繰り返し見出し（「対応」「種別」「手順」）だった。この artifact 群は [ADR 0039](../adr/0039-retire-docs-requests-artifacts.md) で削除済み。2026-08-31 時点の tree では有効にしても 0 件で、無効化の原因は消えている。
  MD024 の目的は、同名見出しから同じ anchor が生成される事故を防ぐこと（`markdownlint` の `doc/md024.md`）。無効のままにしていたのは、anchor link が無く、防ぐ対象が無かったため。2026-11-08 時点では、tracked の Markdown に、repo 内の別ファイルの見出しを指す anchor link が 5 件ある（`README.md` に 2、`docs/notes/` に 2、`docs/adr/` に 1）。この理由は成り立たない。入れ直すかは未判断（[TODO.md](../../TODO.md)）。入れ直す時は、既定ではなく `"MD024": { "siblings_only": true }` にする。MD024 は自動修正を持たず、既定の `siblings_only: false` のままだと、changelog 型の繰り返し見出しを書いた時に commit が止まり、手で直すことになる。

## 未確認

- `check-toml` / `check-yaml` は登録されていない。TOML は `tombi-lint` が構文も見る。YAML は `nvim.yml` などの対象があるが、意図的に外したのか未検討なのかは不明。
