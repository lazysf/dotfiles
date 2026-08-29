# harness の設計原則

- Date: 2026-08-29
- 出典: `dot_claude/` / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この環境での実測

この harness に何を置き、どう書くかの判断基準を残す。個別の設定や skill が今の形である理由は、それぞれの設計 note にある。

## surface へ昇格する基準

新しく得た調査結果や運用知見は、まず `docs/` に repo-level knowledge として残す。そこから `dot_claude/` へ上げるのは、展開後にも価値があり、workspace 横断で再利用するものだけ。配布する設定が増えると、全 project で常時 load とメンテの対象が増える。

## skill description の書き方

`description` は skill の主な発火面で、ここに書いた語で呼ばれるかが決まる。

- ユーザーが言いそうな依頼語を先頭に置く。何をする skill かより、どんな時に呼ぶかを先に読ませる。
- その skill が何を整理・実行・出力するかを示す。
- 近接 skill との差分、渡し先、対象外を明示する。
- 他の skill や agent を案内する時は「〜したい時は `skill-name` スキルを使う」のように surface 種別まで書く。skill 名の裸参照だけで意味を持たせない。
- 短さより境界語の明確さを優先する。

文数の上限は置かない。公式も "a few sentences to a short paragraph" を目安としている。

## AGENTS.md の URL 表を notes へ移さない理由

root `AGENTS.md` は公式ページへの URL 表を持つ。これを `docs/notes/` へ移し、契約には参照義務と index リンクだけ残す案を検討して見送った。

- root `AGENTS.md` は `.chezmoiignore` で配布対象外なので、他 project の常時 load はもともと増えていない。効果はこの repo のセッション限定。
- 一方この表は実際に機能した。in-process tool が sandbox の対象外であること、auto mode の allow drop 対象リスト — どちらも表から正しいページへ辿って確認できた。記憶で答えていれば誤っていた。
- 移すと indirection が 1 段増え、index を読まずに済ませる経路ができる。数十行の節約と引き換えに参照義務の実効を賭けることになる。

再検討の条件は、表が肥大して契約本文が読めなくなった時。その場合も「表は残して重複した導入文だけ削る」を先に試す。
