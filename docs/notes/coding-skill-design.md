# coding skill の設計

- Date: 2026-11-10
- 出典: [Best practices](https://agentskills.io/skill-creation/best-practices) / [Specification](https://agentskills.io/specification) / [Extend Claude with skills](https://code.claude.com/docs/en/skills) の frontmatter の `paths`（2026-11-10 確認） / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / `dot_claude/skills/coding/` / Windows の作業機の session の記録の集計と、probe skill での `paths` の実測（2026-11-10、Claude Code 2.1.321） / この環境での実測

`coding` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。各項目の直接の理由は、skill の本文がその項目の中に書いている。ここでは繰り返さない。

## 残す基準

skill には、Claude が既定ではしないことだけを置く。Best practices の "Would the agent get this wrong without this instruction?" に答えて、No になる内容は置かない。品質の優先順位や基本原則のように Claude が既定で持つか、`CLAUDE.md` が常時 load で持つ内容は、ここで繰り返さない。

## `paths` を付けている理由

description だけでは、コードを編集する session で発火しなかった。Windows の作業機の session の記録 36 本（2026-11-01〜11-10）のうち、コードファイルを Edit か Write で編集した session は 6 本で、この skill が発火したのは 2 本だった。2026-11-10 の 3 本は、コードの編集が 49、86、100 回あり、発火は 0 回だった。コードファイルは拡張子で判定し、日付は記録のファイルの更新日で数えた。

`paths` は、一致するファイルを触った時に skill を一覧へ出す。読み込みは起こさない。`~/.claude/skills/` に probe skill を置いて確かめた（2026-11-10、Claude Code 2.1.321）。

- 一致するファイルを触る前は、skill は一覧に無く、名前で呼んでも `Unknown skill` になった。`claude -p` の起動時の情報でも、`paths` 付きの skill は一覧に載らず、`paths` の無い同じ skill は載った。
- Read で一致するファイルを読むと、直後に skill の名前と description が一覧として届いた。本文は届かず、名前で呼ぶと読み込まれた。
- Write で一致する新しいファイルを作った時と、Edit で一致するファイルを編集した時も、直後に一覧として届いた。
- Bash では届かなかった。試したのは、`cat file | head`、pipe の無い `cat file`、redirect でのファイルの作成の 3 つ。rule の `paths` は pipe の無い `cat file` で注入されるので（[memory-surface-design.md](./memory-surface-design.md)）、skill の `paths` とは動きが違う。
- 書式は、1 行の文字列、YAML の list、直下のフォルダを指す `src/**`、brace でまとめた `**/*.{a,b}` のどれも通った。

配布した `coding` 自身も、apply の後に開いた session で同じ動きをした（2026-11-10、desktop app、model は Fable 5.2）。起動時の一覧に `coding` は無く、名前で呼ぶと `Unknown skill` になった。`dot_config/nvim/init.lua` を Read した直後に、`coding` だけを載せた一覧が届き、その後は名前で呼ぶと本文が読み込まれた。apply を挟んだ古い session では、Read の後に呼べるようにはなったが、一覧は届かなかった。その session は、起動時に `coding` を一覧で受け取っていた。

狙いは、一覧が届く時点をコードを触った直後へ移すこと。`paths` が無い skill の一覧は、session の最初に載る。その後に再提示されるかは確かめていない。読み込むかは、`paths` を付けても model が description で決める。

代償は 4 つある。

- 一致するファイルを触るまで、skill が model から見えない。コードを一から書く時は、最初のファイルを skill なしで書く。
- `paths` のどれにも一致しないコードでは、description でも発火しなくなる。`paths` は、作業ディレクトリ直下の `src/` と、拡張子の列挙の 2 種類を持つ。どちらかに一致すれば一覧に出る。`src/` は列挙に無い拡張子を拾い、拡張子は `src/` を持たない repo（この dotfiles など）を拾う。残るのは、`src/` の外にあって列挙に無い拡張子のコードと、拡張子の無い script。列挙は `SKILL.md` を正本とする。
- `src/` は直下だけを見る。`packages/foo/src/` のような深い位置の `src/` は、拡張子でしか拾わない。`**/src/**` にしていないのは、直下で足りるというユーザー判断による（2026-11-10）。
- `paths` は Claude Code の frontmatter なので、Codex の skill には入れていない。

path 条件付きの rule を使わない判断（[memory-surface-design.md](./memory-surface-design.md) の「`paths` を使わない」）とは対象が違う。あちらは rule の本文を注入する仕組みで、こちらは skill を一覧へ出す仕組み。

発火が増えなければ外す。比べ方は上の集計と同じで、コードを編集した session のうち、この skill が発火した数を数える。

## コメント marker を `tradeoff:` にしている理由

marker の書式は `SKILL.md` を正本とする。上限と作り直す条件の両方を書かせているのは、条件が無い marker が、後から読んだ人には放置と区別が付かないため。`rg -i 'tradeoff:'` は marker を集められるが、条件が書かれているかは判定できない。検査は作らず、marker が溜まってから判断する。

security に関わる上限を marker の対象から外した。`CLAUDE.md` の「確認してから進めること」が要求する人への確認を、コメント 1 行が代替する形になるため。`# tradeoff: token 比較は == のまま。timing attack が問題になったら constant-time へ` は、書式としては規約に完全に適合してしまう。marker の作り直す条件は「〜が問題になったら」という事後のトリガで、security ではその時点が侵害後を意味する。

語を `tradeoff:` にしたのは、意図的な簡略化の理由がトレードオフだから。ponytail の `ponytail:` をそのまま使うと、全 project へ配る成果物に外部プロダクト名が残る。ponytail を参照しなくなった後も語だけが残る。

この repo では marker が 0 件（2026-11-09、Markdown を除く tracked file を `rg` で検索）。この repo のコードは Neovim の Lua 設定が大半（tracked file の拡張子で Lua 28 / sh 6 / ts 4）なので、規約が効くのは主に配布先の project になる。

## 未確認

- `paths` を付けた後、コードを編集する session で発火が増えるか。
- mac の作業機での集計と、mac での `paths` の動き。
