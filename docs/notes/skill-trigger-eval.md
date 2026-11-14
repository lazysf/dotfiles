# skill の発火試験の回し方

- Date: 2026-11-14
- 出典: skill-creator の `scripts/run_eval.py` / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / [Extend Claude with skills](https://code.claude.com/docs/en/skills) の `skillOverrides` / [Claude Code settings](https://code.claude.com/docs/en/settings) の `--settings` と `--effort`（いずれも 2026-11-13〜14 確認） / macOS の作業機で `lapidary` の description を比べた実測（2026-11-13〜14、desktop app 同梱の Claude Code 2.1.321）

skill-creator の `run_eval` で、description ごとに skill が発火するかを比べる時の注意と手順を残す。`lapidary` の description を比べた時に踏んだことから書いている。試験の結果そのものは [lapidary-skill-design.md](./lapidary-skill-design.md) にある。

## 使用量

回す前に、起動する回数、model、effort をユーザーに示して確認を取る。規定の正本は、共通の契約（`dot_claude/CLAUDE.md` と `dot_codex/AGENTS.md`）の「確認してから進めること」にある。`run_eval` は依頼 1 本ごとに `claude -p` を起動する。各回は新しい Claude Code の session で、system prompt、`CLAUDE.md`、tool の定義、skill の一覧を毎回読み込む。依頼の文が短くても、1 回は軽くない。

`lapidary` の比較では、2 日で合わせて約 620 回、Opus 5.5 で起動した。1 日目（2026-11-13）の約 200 回のうち 96 回は、下の「並列の依頼が互いの command を拾う」で結果が無効になった。2 日目（2026-11-14）は、同じ 5 時間の枠の中で約 418 回起動し、約 10 分で枠の約 90% を使った（使用量はユーザーの報告）。6 本の並列で回したので、短い時間に集中した。

見積もりを示す時は、回数と model に加えて、5 時間の枠に対する重さの目安も添える。回数だけでは、ユーザーは重さを判断できない。目安には、上の 2 日目の実績を使う。Pro プランで、Opus 5.5 の起動 1 回が枠の約 0.2% にあたる（90% ÷ 418 回）。この値は多めに見た上限で、次の理由で正確ではない。

- 同じ枠を、試験を指示していた session 自身も使っていた。その分を切り分けていない。
- effort が何で動いたか確かめていない（下記）。
- prompt の cache がどれだけ効いたか記録していない。
- プランと model が変われば値も変わる。使用量の計算の仕方は公開されていない。

desktop app では、今の枠の使用率を、ユーザーは使用量の画面で、agent は使用量を読む tool で確かめられる（2026-11-14、desktop app の session で確認）。少数を回して使用率の増え方を見てから全体を回せば、目安を今の条件で測り直せる。この方法はまだ試していない。

effort は指定しなかった。`--effort` を渡さず、`settings.json` にも `effortLevel` が無い。親の session から `CLAUDE_EFFORT=medium` を引き継いでいたが、CLI がこの変数を読むかは確かめていない。

次の順で回すと、Opus の呼び出しを減らせる。この順はまだ試していない。

| 段階 | model | 目的 | 回数の目安 |
| --- | --- | --- | --- |
| runner と依頼の組を確かめる | Haiku | runner の不具合、環境の問題、依頼の書き方を直す | 数十回 |
| 案を絞る | 実際に使う model、`--effort low`、各 1 回 | 差が出る案と依頼を見つける | 案の数 × 依頼の数 |
| 確かめる | 実際に使う model、`--effort low`、3 回 | 差が出た依頼だけ回し直す | 数十回 |

発火を決めるのは、実際の session の model が description を読む判断なので、結論は実際に使う model で出す。Haiku の結果は、runner と依頼の組が動くかの確認にしか使わない。どれだけ積極的に skill を使うかは model ごとに違う。

本番の前に、依頼 1 本を 1 回だけ回して、発火の判定が正しいかを確かめる。下の「最初の tool だけを見る」の方法で、model が最初に何を呼んだかを表示すれば分かる。`lapidary` の比較では、これを省いたので、無効な 96 回を回した。

## CLI と認証

`claude` は PATH に無かった。desktop app 同梱の CLI を使う。

- macOS の置き場は `$HOME/Library/Application Support/Claude/claude-code/<version>/<build>/claude.app/Contents/MacOS/claude`。`<build>` が複数ある時は、更新日の新しい方を使った。
- `claude-code-vm/` の下にある `claude` は Linux 向けの実行ファイルで、macOS では動かない。
- 同梱の CLI は、desktop app とは別にログインする。token が切れていると、API が `401 OAuth access token has expired` を返す。sandbox の中からはログインも token の更新もできなかった。ユーザーが手元の terminal で `claude auth login` を実行する。
- 2026-11-13 にログインした token は、翌日の次の session では切れていた。どれだけ持つかは測っていない。
- 試験が終わったら、ユーザーが `claude auth logout` でログアウトする。ログアウトしても、desktop app の session は止まらなかった。

sandbox の中では、Bash の `allowed_domains` に `api.anthropic.com` を足す。telemetry と MCP の宛先は拒否されるが、試験は完了する。

## skill-creator の script を動かす

- **Python の版**: `run_eval.py` は `str | None` の型注釈を使うので、Python 3.10 以上が要る。Command Line Tools の `python3` は 3.9 で、起動時に `TypeError` で止まった。uv で入れた 3.14 で動いた。
- **並列の方式**: `run_eval` は `ProcessPoolExecutor` で並列に回す。sandbox の中では、セマフォの上限の確認が `PermissionError` で止まった。各依頼は別の `claude -p` process で走るので、thread で並列にすれば足りる。
- **試験用の command の置き場**: `run_eval` は、試験する description を `<project root>/.claude/commands/<skill 名>-skill-<乱数>.md` に置き、終わったら消す。project root は、作業ディレクトリから親へ `.claude/` を探して決める。skill-creator の directory で `python -m scripts.run_eval` を実行すると、親を辿って home の `.claude/` に当たり、`~/.claude/commands` に書こうとする（コードを読んで確かめた。実行はしていない）。一時 directory に `.claude/` を作り、そこを作業ディレクトリにして、`PYTHONPATH` に skill-creator の directory を渡して起動する。

## 結果を歪めるもの

### 並列の依頼が互いの command を拾う

並列の依頼が同じ project root を使うと、同じ `.claude/commands` に試験用の command が複数並ぶ。model が他の依頼の command を選ぶと、`run_eval` は発火しなかったと数える。`lapidary` の比較では、同じ description が並列では 16 本中 8 本、依頼ごとに別の project root で回すと 16 本中 15 本だった。依頼ごとに一時 directory を作って、そこで回す。

### 配布済みの同じ skill が並ぶ

配布済みの skill（`~/.claude/skills/<name>`）は、試験用の command と並んで一覧に出る。model が配布済みの方を選ぶと、発火しなかったと数える。`--settings` で `skillOverrides` を渡して、配布済みの skill を隠す。stream-json の最初の `system` / `init` の event の `skills` から、その skill が消えたことを確かめた。

### 空の directory

空の directory では、「今の diff を見て」のような依頼が実態と合わない。commit していない変更を持つ小さな git repo を用意して、依頼ごとに複製する。`lapidary` の比較では、空の directory と git repo の複製の両方で回した 16 本の依頼は、どちらでも同じ結果だった。

### 最初の tool だけを見る

`run_eval` は、model が最初に呼んだ tool が `Skill` か `Read` で、試験用の command を指していれば発火と数える。ほかの tool を呼んだ時点で、発火しなかったと決める。長い作業の途中で、頼まれずに発火するかは測れない。

1 本の依頼の最初の動きを見る時は、`--max-turns 1 --output-format stream-json --verbose` で回し、最初の `assistant` の event の `tool_use` を表示する。

## 依頼の組と判断

- [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) に従い、発火すべき依頼と、隣の skill や command へ行くべき依頼を半々にする。隣へ行くべき依頼は、取り違えやすいもの（doc の点検、他人の変更の見直しなど）にする。
- 依頼の組は、回す前にユーザーに見せる。
- 落ちた依頼に合わせて description を直したら、その後で書いた依頼で確かめる。`lapidary` では、落ちた 3 本の言い回しを並べた案がその 3 本を拾ったが、後から足した依頼では差が無かった。
- どの案も同じ結果なら、短い方を選ぶ理由にはなるが、変える理由にはならない。変えた後の説明に効く部分は残してよい。

## 起動の例

試験用の一時 directory の外に、次の 2 つを置く。

`claude` の wrapper（PATH の先頭に置く）。配布済みの skill を隠す。

```sh
#!/bin/sh
exec "$HOME/Library/Application Support/Claude/claude-code/<version>/<build>/claude.app/Contents/MacOS/claude" \
  --settings '{"skillOverrides":{"<skill 名>":"off"}}' "$@"
```

`run_eval` を thread で回し、依頼ごとに別の project root を使う起動用の script。`LAPEVAL_TEMPLATE` に git repo の雛形を渡すと、それを複製する。

```python
import os, shutil, tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import scripts.run_eval as run_eval

_original = run_eval.run_single_query


def _isolated(query, skill_name, description, timeout, project_root, model=None):
    root = Path(tempfile.mkdtemp(prefix="q-", dir=project_root))
    template = os.environ.get("LAPEVAL_TEMPLATE")
    if template:
        shutil.copytree(template, root, dirs_exist_ok=True)
    (root / ".claude").mkdir(exist_ok=True)
    try:
        return _original(query, skill_name, description, timeout, str(root), model)
    finally:
        shutil.rmtree(root, ignore_errors=True)


run_eval.ProcessPoolExecutor = ThreadPoolExecutor
run_eval.run_single_query = _isolated
run_eval.main()
```

`run_eval` は CLI の flag に `--model` しか渡さない。effort を指定する時は、wrapper に `--effort low` を足す。

試験の後は、一時 directory と scratchpad の試験ファイルを消す。`lapidary` の比較では、`~/.claude/projects` と `~/.claude.json` に試験の記録は残らなかった。

## 未確認

- `CLAUDE_EFFORT` を CLI が読むか。読まない場合の、Opus 5.5 の既定の effort。
- Haiku と Opus で、1 回あたりの使用量がどれだけ違うか。
- 上の段階的な順で回した時に、実際にどれだけ使用量が減るか。
- Windows での同梱の CLI の置き場と、同じ手順が通るか。
- 同梱の CLI の token がどれだけ持つか。
