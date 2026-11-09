# lint / pre-commit の実行経路

- Date: 2026-11-09
- 出典: `prek.toml` / `scripts/check-identifiers.sh` / `scripts/check-commit-msg.sh` / [prek Configuration](https://prek.j178.dev/configuration/) / [prek Configuration Reference](https://prek.j178.dev/reference/configuration/) / [prek Local Hooks](https://prek.j178.dev/local-hooks/) / [tombi-toml/tombi-pre-commit](https://github.com/tombi-toml/tombi-pre-commit) / `node_modules/.bin/tombi --help` / `.rumdl.toml` / `package.json` / `.git/hooks/pre-commit` / `prek --version` / 使い捨て repo での `git commit` 実測 / [rumdl](https://github.com/rvben/rumdl) / [rumdl Global Settings](https://rumdl.dev/global-settings/) / [rumdl Stability and Compatibility](https://rumdl.dev/stability/) / [rvben/rumdl-pre-commit](https://github.com/rvben/rumdl-pre-commit)（2026-11-09 確認） / rumdl 0.3.2 での repo 全体の実測と、`rumdl config --defaults`（2026-11-09） / markdownlint 0.40.0 の API による rule 単体実測 / commit `287cc7b` `be928f2`

Markdown（rumdl）と TOML（tombi）の lint は、それぞれ「手で走らせる経路」と「commit 時に走る経路」の 2 本ある。同じ設定ファイルを読むが、実行する binary は別。設定を触る前にどちらが動くかを取り違えないための記録。

hook の一覧と設定値は `prek.toml` と `.rumdl.toml` を正本とし、ここでは繰り返さない。

## 2 本の経路

| 経路 | 起動 | 実行される binary |
| --- | --- | --- |
| 手動 | `npm run lint` / `npm run lint:fix` | repo の `node_modules/rumdl` |
| commit 時 | `git commit` → `.git/hooks/pre-commit` | prek が `rvben/rumdl-pre-commit` から用意した hook 環境の `rumdl` |

どちらも `.rumdl.toml` を読み、2026-11-09 時点はどちらも 0.3.2 なので判定は揃う。version を上げる時は `package.json` の dependency と `prek.toml` の `rev` の両方を動かさないと、この 2 経路がずれる。

`package.json` は rumdl を `^` を付けずに完全固定している。rumdl は Beta で、公式の方針では 0.x の minor release に breaking change が入りうる。新しい rule が既定で有効になって、指摘が増えることもある。公式は、結果を揃えたいなら版を完全に固定するよう勧めている。固定すると、版を上げた時だけ判定が変わる。

## TOML の tombi も同じ 2 本

| 経路 | 起動 | 実行される binary |
| --- | --- | --- |
| 手動 | `npm run lint:toml` / `npm run lint:toml:fix` | repo の `node_modules/tombi` |
| commit 時 | `git commit` → `.git/hooks/pre-commit` | prek が `tombi-toml/tombi-pre-commit` から用意した hook 環境の `tombi` |

どちらも `.tombi.toml` を読む。VS Code の tombi 拡張も同梱の tombi で判定する。2026-11-08 時点で 3 つとも 1.10.0。version を上げる時は、`package.json`、`prek.toml` の `rev`、VS Code 拡張の 3 つを揃える。

hook は `uv.lock` を対象から外している。prek は `uv.lock` を `toml` と判定するので、外さないと tombi-format が uv の生成物を書き換える（2026-11-08 に `--all-files` で発生）。手動の経路は `.tombi.toml` の `**/*.toml` だけを見るので、外すと 2 経路の対象が揃う。

`tombi format --diff` は差分を表示するだけでなく、ファイルを書き換える（1.10.0、2026-11-08）。差分だけ見たい時は `--check` を使う。

## runner は pre-commit ではなく prek

`.git/hooks/pre-commit` は prek（`/opt/homebrew/bin/prek`、2026-11-09 時点 0.5.10）が生成したもので、`prek hook-impl` へ委譲する。hook は設定ファイルの名前を持たず、prek が実行時に探す。Python の `pre-commit` は install されていない。

設定は prek 独自の `prek.toml` に置く。Python の `pre-commit` を使わないので、`.pre-commit-config.yaml` で互換を保つ利点が無い。hook は配列テーブル（`[[repos.hooks]]`）で書く。`prek util yaml-to-toml` の出力は複数行のインラインテーブルを使うが、tombi の format はこれを 1 行に詰め、hook の一覧が読めなくなる（tombi 1.10.0、2026-11-08）。配列テーブルなら tombi の format を通っても形が変わらない。`.pre-commit-config.yaml` を置き直さない。prek は同じ directory に両方あると `prek.toml` を優先し、どちらが効いているか分かりにくくなる。

`prek.toml` は `.` で始まらないので、`.chezmoiignore` に載せないと home へ配布される。

hook の `rev` は commit SHA でなく tag で固定している（2026-11-08 のユーザー判断）。tag は付け替えられるので、厳密な固定ではない。付け替えた後に cache の無い状態で commit すると、別の code が走る。cache の無い状態は、新しい作業機の立ち上げ、cache の削除、`rev` の更新で生じる。人が terminal から commit すると、その code は sandbox の外で人の権限で走る。それでも tag にしているのは、3 つの hook repo がどれも各 tool の公式のもので、`rev` を上げる時に版が読めるため。hook repo に lockfile は無く、hook 環境の推移的な依存は install の時点の semver の範囲で決まる。SHA で固定しても、この揺れは残る。固定を見直すなら、SHA にして tag を行末のコメントに残す形にする。

hook の実行環境（Node / Python）は prek が `~/.cache/prek/` 配下へ自前で用意する。repo の `node_modules` や `.venv` は使わない。sandbox で `~/.cache/prek/` への write を許可しているのはこのため（[claude-code-settings-design.md](./claude-code-settings-design.md)）。

## rumdl の hook は `rumdl-check` だけを使う

`rvben/rumdl-pre-commit` は `rumdl-check`（lint、`--fix` で修正）と `rumdl-fmt`（format）の 2 つを持ち、公式は両方を並べる形を勧めている。この repo は `rumdl-check` に `--fix` を付けて 1 つだけ使う。`--fix` で自動修正できる指摘は直り、直せない指摘は exit 1 で commit を止める。`rumdl-fmt` は残った指摘があっても exit 0 で抜けるので、足しても止める役は増えない。

hook が発火するのは staged に `.md` がある時だけ（hook 定義の `types: [markdown]`）。rumdl は引数で渡した file だけを見る。2026-11-09 に、違反を仕込んだ file を `prek run rumdl-check --files` で渡すと、hook は exit 1 で止まった。MD089 の指摘は直り、自動修正の無い MD024 の指摘は残った。

hook が file を書き換えると、prek はその commit を失敗させ、修正は unstaged の変更として working tree に残る。修正を確かめてから stage し直す。対象の file に unstaged の変更がある時は、prek が hook の前に unstaged 分を patch へ退避する。hook の修正がその patch と衝突すると、hook の修正は捨てられて退避分が戻る。この時は手で直す。書き換える hook の一覧と失敗時の扱いは [git-commit-skill-design.md](./git-commit-skill-design.md) にある。

## rule の選び方

rumdl の既定の rule に、次の 2 つの調整を加えている。

- `MD013`（line-length、既定 80）を無効にしている。この repo の Markdown は日本語の段落を 1 行で書き、hard wrap しない。rule 自体が書き方と噛み合わない。markdownlint の時代の 2026-08-31 の tree で有効に戻すと 460 件出た。無効にした `287cc7b`（2026-04-21）には理由の記載が無い。
- `MD089`（cjk-spacing）を足している。日本語と英数字の間に半角の空白を入れる書き方を、自動修正で揃える。rumdl の独自の rule で、既定では無効になっている。2026-11-09 の tree で有効にすると 4 件出た。うち 3 件はリンクの直後に日本語が続く箇所で、リンクの後に空白を入れる形に揃えた。

ADR も含めて、全 file に同じ rule を当てている。ADR で守るのは何を決めたかで、書式ではない。rumdl を入れた時（2026-11-09）は、ユーザーの判断で ADR の本文の書式も rule に合わせて直した。

`MD024`（no-duplicate-heading）は有効にしている。rumdl の既定は `siblings-only = true` で、同じ親の下の同名の見出しだけを止める（`rumdl config --defaults`、0.3.2）。2026-11-09 の tree では 0 件だった。tracked の Markdown には repo 内の別 file の見出しを指す anchor link があり、同名の見出しは anchor を取り違える原因になる。markdownlint の時代は無効にしていた。導入時（`be928f2`）の tree で有効にすると、削除済みの `docs/requests/**/test.md` の繰り返し見出しで 164 件出たため。

## 作業機の識別子を検査する local hook

`check-identifiers`（`scripts/check-identifiers.sh`）は、staged のファイルの path と追加行に、この作業機の識別子が無いかを調べる。`CLAUDE.md` の Privacy 節は識別子を成果物に残さないと定めるが、契約は Claude が読む指示であって、強制ではない。この repo は public で、push した値は後から消しても残る。

調べる値は 3 つで、どれも実行時に読む。`$HOME`（末尾の `/` は外す）、`${USER:-$USERNAME}`、`hostname` の出力の最初のラベル。値を script に書くと、script 自体が値を配る。`$HOME` は固定文字列で探す。ユーザー名とホスト名は、語単位で、大文字と小文字を区別せずに探す。stderr には種類と path だけを出し、当たった行の内容は出さない。削除した path は見ない。値を含む path を消す commit を止めないため。

staged の差分は 1 回だけ取り、追加行の path は diff の header から読む。ファイルごとに path を指定して diff を取り直すと、git がクォートした path（`"`、`\`、tab を含む名前）がどのファイルにも当たらず、中身を検査しないまま通る。`--text` を付けるのは、`.gitattributes` で `binary` や `-diff` を付けたファイルの中身も検査するため。差分を取れない時は、検査を飛ばさずに止める。`always_run` を付けるのは、prek が file type で対象を絞ると、symlink だけの commit で hook が起動しないため。script は staged の一覧を自分で集める。

git の pre-commit として動かすのは、git が commit 先の repo の、stage した後の index で hook を動かすから。Claude の commit なら、hook は sandbox の中で動く。先に Claude Code の `PreToolUse` hook で同じ検査を作り、捨てた（2026-11-08）。`PreToolUse` の hook の入力で、commit 先の repo の手がかりになるのは、command の文字列と session の cwd だけ。`cd <dir> && git commit` や `git -C <dir> commit` で別の repo を指す形と、同じ command で stage する分は、文字列を解釈して追うしかなかった。hook は sandbox の外で動くので、repo の設定に書かれた program（fsmonitor、external diff など）を起動しない保護も要った。script は 140 行まで膨らみ、直すたびに別の穴が見つかった。代わりに、この local hook は入れた repo でしか効かず、clone ごとに `prek install` が要る。入れ忘れると黙って効かない。hook の起動に関わるもののうち、`.git/hooks` と `.git/config` は、Claude Code の sandbox の中から書き込めない（2026-11-08、mac の session で `touch` が拒否された）。sandbox の中から書けるのは `prek.toml` と `scripts/` で、どちらも書き換えれば diff に出る。

拾わないものは、commit message、`--no-verify` を付けた commit、pattern にできない識別子（実名、メールアドレス、社内のホスト名）。`$HOME`、ユーザー名、ホスト名のうち取れなかった値は、その種類の検査を飛ばす。

2026-11-08 に macOS で、使い捨ての repo に stage して script を直接呼んだ。

- 止まった（exit 1）: home の追加行、ユーザー名の語、ユーザー名を含む非 ASCII の path、値を含むファイルの改名、cwd が subdirectory の時、`"`・`\`・tab を含む名前のファイルの中身、home を指す symlink、`binary` 属性を付けた text ファイル、差分を取れない時。
- 通った（exit 0）: ユーザー名を一部に含む別の語、該当なし、値を含むファイルの削除、staged が空の時。

同じ日に、使い捨ての repo に `prek install` して `git commit` した。home を指す symlink だけの commit と、`"` を含む名前のファイルの commit は、`check-identifiers` が Failed で止めた。値の無い commit は通った。

## commit message の title を検査する hook

`check-commit-msg`（`scripts/check-commit-msg.sh`）は commit-msg の段で走り、title が `<type>: <description>` の形かを見る。規約の正本は `dot_claude/skills/git-commit/SKILL.md` で、hook は title の形だけを機械的に見る。理由は [git-commit-skill-design.md](./git-commit-skill-design.md) の「title の規定」。

`prek.toml` は `default_install_hook_types` に `commit-msg` を足し、`default_stages` を `pre-commit` に絞っている。prek の docs では、`stages` を書かない hook は全 stage が対象で、`default_install_hook_types` の既定は `[pre-commit]`（[prek Configuration Reference](https://prek.j178.dev/reference/configuration/)、2026-11-09 確認）。使い捨ての repo で commit-msg の shim を入れて試すと、`stages` を書かない local hook が commit-msg の段でも走り、1 回の commit で 2 回動いた。`default_stages = ["pre-commit"]` を足すと 1 回になった。commit-msg の hook には message file の path が 1 つだけ渡された（2026-11-09、prek 0.5.10）。

commit-msg の shim は `prek install` で入る。shim を足す前に `prek install` した clone は、打ち直すまで検査されない。`.git/hooks` は Claude Code の sandbox の中から書けないので、打つのは人。

## `.ps1` の BOM を検査する hook

`check-ps1-bom`（`scripts/check-ps1-bom.sh`）は、staged の `.ps1` が UTF-8 の BOM で始まるかを見る。Windows PowerShell は、BOM の無い UTF-8 のスクリプトを ANSI のコードページで読み、非 ASCII の文字を読み違える（[about_Character_Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-5.1)、2026-11-09 確認）。`Documents/WindowsPowerShell/` の profile と `scripts/windows/setup.ps1` は日本語を含み、Windows PowerShell で動く。

改行は `.gitattributes` の `eol=lf` が git の側で揃えるが、git は UTF-8 の BOM を足しも消しもしない。エディタや agent の編集 tool が BOM を落としても、git は気づかない。そのため BOM だけは hook で止める。直しはせずに止めるだけにしている。BOM を足すと、ファイルの先頭の byte が変わるため。

対象は拡張子が `.ps1` の file だけで、大文字と小文字は区別しない（`files = '(?i)\.ps1$'`）。Windows では `setup.PS1` のような名前でも PowerShell のスクリプトとして動くため。PowerShell 7 の profile は `.ps1.tmpl` で、chezmoi の template の記法から始まるので外れる。PowerShell 7 は BOM の無い UTF-8 を既定で読む。

script は file を `od -N3` に入力のリダイレクトで渡し、先頭の 3 byte を読む。引数で渡すと、`-` で始まる名前を option と読み違えて失敗するため。`od` が失敗した時は、BOM の判定とは分けて「読めない」と報告する。

2026-11-09 に、script を直接呼ぶと、BOM 付きは名前が `-` で始まっても exit 0、BOM の無いもの、空の file、存在しない path、読む権限の無い file は exit 1 だった。`prek run check-ps1-bom --files` でも、BOM の無い `.ps1` と `.PS1` で止まり、BOM 付きでは通った。`.ps1.tmpl` は対象にならなかった。

## 未確認

- `check-identifiers`、`check-commit-msg`、`check-ps1-bom` が Windows の prek で動くか。`check-commit-msg` は文字数を `LC_ALL=en_US.UTF-8 wc -m` で数える。`check-ps1-bom` は `od` と `tr` を使う。
- rumdl の hook と `npm run lint` が Windows で動くか。
- VS Code の rumdl 拡張が `.rumdl.toml` を読んで同じ判定をするか。拡張は入れていない。
- `check-toml` / `check-yaml` は登録されていない。TOML は `tombi-lint` が構文も見る。YAML は `nvim.yml` などの対象があるが、意図的に外したのか未検討なのかは不明。
