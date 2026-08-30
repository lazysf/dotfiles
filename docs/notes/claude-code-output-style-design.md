# Claude Code Output Style の設計

- Date: 2026-08-28
- 出典: [Output styles](https://code.claude.com/docs/en/output-styles) / [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) の `skills/caveman/SKILL.md` / `dot_claude/output-styles/caveman.md`

`caveman` output style が今の形になっている理由を残す。ファイルを読んでも分からない前提と制約に絞る。

## 公式に caveman は無い

Claude Code の built-in output style は Default / Concise / Proactive / Explanatory / Learning の 5 つで、`caveman` は含まれない。GitHub で見つかるものはすべて個人の非公式実装。

**Concise（v2.1.237 以降）の規定が自作 caveman と大きく重なる。** 結果を先に出し、preamble と narration を省き、既定で短く返す。error report、security warning、破壊的操作の確認は完全な内容を保つ。caveman を捨てるなら Concise が第一候補。

## skill でなく output style である理由

参考にした JuliusBrussee/caveman は skill だが、Claude Code 単独では output style が優る。

- **遵守リマインダー**: output style は会話中に harness がリマインダーを自動注入する（公式: "All output styles trigger reminders for Claude to adhere to the output style instructions"）。skill にこの仕組みは無い。JuliusBrussee 版が SKILL.md の Persistence 節に "Keep terse on long sessions no filler drift" と書いているのは、この欠落を prompt で補うため。
- **token**: output style は system prompt に入るため prompt cache が効く。JuliusBrussee 版は README で "the skill itself adds ~1–1.5k input tokens per turn" と明記し、既に簡潔な作業では net-negative になり得るとしている。
- **発火**: `outputStyle` 設定で常時有効。skill は invoke か auto-trigger 頼みで確実でない。

JuliusBrussee 版が skill なのは移植性（Claude Code 以外の 30 以上の agent へ対応）のため。Claude Code 単独ならこの理由は当たらない。

## 強度切替が style ファイル内にある理由

ファイルを分けて `/config` で選ぶ形は採れない。output style は session 開始時に一度だけ読まれ、変更は `/clear` か新しい session でしか反映されない（公式: "reads once at session start"）。session 途中に切り替えられない。

`/caveman ultra` の slash 形も採れない。`/` 始まりの入力は skill 名として解決されるため、skill でない output style には作れない。

`caveman lite` のように接頭辞を必須にしているのは、裸の `lite` が「lite 版のライブラリ」のような文脈で誤発火するため。切替の実効は LLM 遵守依存で、機械的な担保は無い。

## 略語と矢印を規定しない理由

JuliusBrussee 版は自作の短縮と因果矢印を明示的に否定している。

> never invent new abbreviations (cfg/impl/req/res/fn) tokenizer split them same as full word: zero token saved, reader still decode. Full word cheaper AND clearer.

矢印も同じ理由で否定している。

> No causal arrows (→) either own token, save nothing.

**「tokenizer で節約ゼロ」は検証していない**（`count_tokens` API は認証が要り、この環境から叩けない）。そのため断定として写さず、「短くならないなら通常形を使う」という共通原則 1 本に集約している。略語・矢印・caveman 語順の 3 つがこれで処理でき、判断基準も揃う。

検証は要らない。略語は引用元自身が "reader still decode" も根拠に挙げており、token の結果に関わらず避ける理由が立つ。矢印は token 根拠しかないが、共通原則が「短くならないなら」と都度の判断に落としているため、事前に一般解を持つ必要がない。

略語を推奨すると `rules/coding-standards.md` の命名規約（ドメインの意味を表す名前を使い、中身を説明しない語を避ける）と衝突する。output style は system prompt を変えるため、文体指示が識別子やコメントへ漏れうる。

## 応答の型と共通規則は別物

`短い回答はこの型に寄せる: [対象] [動作] [理由]. [次の手]。` は、共通規則の「前置き、tool 実行の予告、進捗、実況を書かない」と重複して見えるが役割が違う。共通規則は**何を削るか**、型は**何を含めどう並べるか**を規定していて、`[理由]` と `[次の手]` は他のどの規定にもない。

JuliusBrussee 版は Pattern の直後に Not / Yes の対比例を置いて意味を確定させている。自作版は共通規則が前置きの除去を明示しているため例を持たず、代わりに使用条件（短い回答に限る）を添えている。条件が無いと、比較表やレビュー結果まで 1 文に畳めと読める。

## 応答言語は settings が持つ

`settings.json` の `language: "japanese"` が応答言語を**固定**する。system prompt に `Always respond in japanese.` として現れる。

caveman.md 側に「ユーザーの言語を保つ」（＝ユーザーが書いた言語への**追従**）を書くと、ユーザーが日本語以外で書いた場合に固定と追従で指示が割れる。そのため style 側は言語を規定しない。

## 成果物への影響

output style は system prompt を変えるため、chat 応答以外にも影響しうる。経路は 2 つ。

- **coding instructions の削除**: custom output style は既定で Claude Code の built-in software engineering instructions（変更範囲の決め方、コメントの書き方、検証の仕方）を落とす。`keep-coding-instructions: true` で保持する。caveman.md はこれを設定している。
- **文体指示の漏れ**: 圧縮の指示がコードコメントや識別子に適用されうる。歯止めは「境界」節の列挙だけで、機械的な担保は無い。列挙漏れがそのまま穴になる。

subagent には output style が適用されない（公式: "Output styles apply to the main conversation only"）。fork のみ例外。

## 未確認

- 強度切替（`caveman ultra` 等）が長い session で維持されるかは未実測。
