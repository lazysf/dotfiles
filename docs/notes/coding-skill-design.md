# coding skill の設計

- Date: 2026-11-09
- 出典: [Best practices](https://agentskills.io/skill-creation/best-practices) / [Specification](https://agentskills.io/specification) / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / `dot_claude/skills/coding/` / この環境での実測

`coding` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。各項目の直接の理由は、skill の本文がその項目の中に書いている。ここでは繰り返さない。

## 残す基準

skill には、Claude が既定ではしないことだけを置く。Best practices の "Would the agent get this wrong without this instruction?" に答えて、No になる内容は置かない。品質の優先順位や基本原則のように Claude が既定で持つか、`CLAUDE.md` が常時 load で持つ内容は、ここで繰り返さない。

## コメント marker を `tradeoff:` にしている理由

marker の書式は `SKILL.md` を正本とする。上限と作り直す条件の両方を書かせているのは、条件が無い marker が、後から読んだ人には放置と区別が付かないため。`rg -i 'tradeoff:'` は marker を集められるが、条件が書かれているかは判定できない。検査は作らず、marker が溜まってから判断する。

security に関わる上限を marker の対象から外した。`CLAUDE.md` の「確認してから進めること」が要求する人への確認を、コメント 1 行が代替する形になるため。`# tradeoff: token 比較は == のまま。timing attack が問題になったら constant-time へ` は、書式としては規約に完全に適合してしまう。marker の作り直す条件は「〜が問題になったら」という事後のトリガで、security ではその時点が侵害後を意味する。

語を `tradeoff:` にしたのは、意図的な簡略化の理由がトレードオフだから。ponytail の `ponytail:` をそのまま使うと、全 project へ配る成果物に外部プロダクト名が残る。ponytail を参照しなくなった後も語だけが残る。

この repo では marker が 0 件（2026-11-09、Markdown を除く tracked file を `rg` で検索）。この repo のコードは Neovim の Lua 設定が大半（tracked file の拡張子で Lua 28 / sh 6 / ts 4）なので、規約が効くのは主に配布先の project になる。
