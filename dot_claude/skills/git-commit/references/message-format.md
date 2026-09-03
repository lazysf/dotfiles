# Commit message 形式

`body` / `footer(s)` / `BREAKING CHANGE` を書く場合だけ読む。
title の規定は `../SKILL.md` を正本にする。

## body

title の後に 1 行空けて書く。通常の英文で、先頭 1 文字は大文字。1 行は概ね 72 文字で折り返す。箇条書きは `-` を使う。

構造化した方が明確なら英語ラベルを使う。ラベルごとに要否が違う。

| ラベル | 内容 | いつ書くか |
| --- | --- | --- |
| `Why:` | 変更が必要になった理由 | body を書くなら原則必要。body の存在理由が「なぜ変えたか」を残すことなので |
| `What:` | 変更点 | **差分から読み取れない時だけ。** 読めば分かる変更を言い換えない |
| `Impact:` | 利用者・運用・互換性・防御層への影響 | 下記の条件を満たす時だけ |

3 つを機械的に揃えない。書くことが無いラベルは省く。

## Impact を書く条件

次のいずれかに当たる時だけ書く。

- 挙動、互換性、防御層が**変わる**。読み手が変更後の状態を知る必要がある。
- 変わらないことを**明示する価値がある**。security 設定や権限を触った commit で「他の層は無傷」と宣言しておくと、後から「この変更が何を弱めたか」を追う人が差分を読み直さずに済む。
- 未完成の状態や復元手段を残す必要がある。途中まで進めた変更や、退避先の branch など。

`Docs only; no behavior change.` のような内容の無い `Impact:` は書かない。影響が無いなら、ラベルごと省く方が読み手の負担が小さい。

## body に書かないもの

- `This commit does X` のような書き出し。diff が何をしたかを語るので、body は理由に集中する。
- `I` / `we` / `now` / `currently`。commit は変更そのものの記録で、書き手や時点の話ではない。
- `As requested by ...`。依頼者を残したいなら `Co-authored-by` trailer を使う。
- ファイル名の再掲。`files` に出るので body で繰り返さない。

## footer(s)

`body`（なければ `title`）の後に 1 行空けて書く。git trailer 形式に準拠する。

- 形式は `Token: value`。トークンは先頭大文字、内部の空白は `-`（`BREAKING CHANGE` は例外）。
- 値は英語・英小文字を既定とする（固有名詞は大文字可）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123`。GitHub の `Closes #123`（コロンなし）ではなく trailer 形式を使う。

## BREAKING CHANGE

`BREAKING CHANGE:` を footer に書くか、`type` 直後に `!` を付ける。任意の型に付けられる。

- `!` がある場合 `BREAKING CHANGE:` は省略できる。その時は `title` の description で内容を説明する。
- `BREAKING CHANGE:` は大文字 + 半角スペース + 説明。

## 例

防御層に触れたので、変わったものと変わらなかったものを両方書く場合。`What` は差分を読めば分かるので書かない。

```txt
fix: drop the env var that forced permission mode to default

Why: CLAUDE_CODE_SUBPROCESS_ENV_SCRUB silently overrides the configured
permission mode, so auto mode never took effect.
Impact: Credential environment variables are no longer stripped from
subprocesses. The credential store deny rules and the sandbox
boundaries are unchanged.
```

互換性が壊れる場合。

```txt
feat!: rename the config key from timeout to timeout_ms

BREAKING CHANGE: config files using `timeout` fail to load. Rename the
key and convert the value from seconds to milliseconds.
```
