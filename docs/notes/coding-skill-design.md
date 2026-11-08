# coding skill の設計

- Date: 2026-11-08
- 出典: [Best practices](https://agentskills.io/skill-creation/best-practices) / [Specification](https://agentskills.io/specification) / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / `dot_claude/skills/coding/` / この環境での実測

`coding` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。

## 残す基準

skill には、Claude が既定ではしないことだけを置く。Best practices の "Would the agent get this wrong without this instruction?" に答えて、No になる内容は置かない。品質の優先順位や基本原則のように Claude が既定で持つか、`CLAUDE.md` が常時 load で持つ内容は、ここで繰り返さない。

残っているのは 2 つ。言語固有の形式と制約は、Claude が既定で書く形式と対象ファイルの形式がずれる場面を扱う。`tradeoff:` は、この環境で決めた規約で、repo を読んでも分からない。

## 言語固有の形式を reference に分ける理由

charset、改行、BOM、必須の metadata、識別子の上限は言語ごとに違い、守らないとファイルが読み込めなくなる。可読性の判断より前に来る性質なので、SKILL.md 本体には言語共通の確認手順だけを置き、言語別は `references/` に分けている。公式が推奨する domain organization の形。

現在 reference があるのは VBA だけ。`.bas` / `.cls` は VBA 専用の拡張子ではない。`.cls` は LaTeX のクラスファイルと Salesforce Apex のクラス、`.bas` は FreeBASIC など他の BASIC 系でも使う。reference の冒頭に「拡張子だけで判断せず、Excel や Office の VBA だと確かめてから適用する」を置いた。`paths` で対象の path を絞らないので、拡張子が同じ別の言語への誤用はこの 1 文で防ぐ。

reference が無い言語のために、SKILL.md 側に確認すべき 3 点を一般則として書いてある。既存ファイルの charset / 改行 / BOM、識別子の上限と使える文字、toolchain が要求する metadata。VBA はその 1 例という位置づけで、言語が増えても SKILL.md を書き換えずに reference を足せる。

## コメント marker を `tradeoff:` にしている理由

marker の書式は `SKILL.md` を正本とする。上限と作り直す条件の両方を書かせているのは、条件が無い marker が、後から読んだ人には放置と区別が付かないため。`rg -i 'tradeoff:'` は marker を集められるが、条件が書かれているかは判定できない。検査は作らず、marker が溜まってから判断する。

security に関わる上限を marker の対象から外した。`CLAUDE.md` の停止線が要求する人への確認を、コメント 1 行が代替する形になるため。`# tradeoff: token 比較は == のまま。timing attack が問題になったら constant-time へ` は、書式としては規約に完全に適合してしまう。marker の再構築条件は「〜が問題になったら」という事後トリガで、security ではその時点が侵害後を意味する。

語を `tradeoff:` にしたのは、意図的な簡略化の理由がトレードオフだから。ponytail の `ponytail:` をそのまま使うと、全 project へ配る成果物に外部プロダクト名が残る。ponytail を参照しなくなった後も語だけが残る。

**この規約は新規で、既存実態は 0 件。** 2026-09-01 時点、Markdown を除く tracked file を `rg` で見て marker は無い。この repo のコードは Neovim の Lua 設定が大半（tracked file の拡張子で Lua 28 / PowerShell 3 / zsh 2 / sh 2）なので、規約が効くのは主に配布先の project になる。
