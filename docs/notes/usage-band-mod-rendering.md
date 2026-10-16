# usage-band mod の描画

- Date: 2026-10-16
- 出典: `dot_claude/mods/usage-band/hooks/register.tsx` / desktop app 同梱の mod API 型定義（v2.1.299）の `BoxProps`、`Space`、`TextProps`、`CodeProps` / 一時 home へ展開した mod での `claude plugin test`（v2.1.292） / desktop app と terminal でのスクリーンショット（2026-10-16）

`usage-band` は全 surface で、バーを `█` と `░` の文字で描く。desktop app では列がずれるが、使用率と残り時間は読めるので許容している。直す時に調べ直さずに済むよう、確かめた制約を残す。

## desktop で列がずれる理由

desktop app は proportional font で描く。`5h` と `週` のラベルは幅が違う。`█` と `░` も幅が違う。

フォント指定では揃わない。

- `Text` の `mono` は型定義にあるが、desktop app は受け付けない（ユーザー確認）。
- `Code` は等幅で描くが、色が構文ハイライトで決まる。使用率に応じたバーの色を付けられない。
- desktop app の Code tab の設定にフォントの項目は無い。

## Box レイアウトなら desktop の列が揃う

1 行を row の `Box` にして、ラベル、バー、% の幅をマス数で固定すると、desktop app でも列が揃う。バーは、埋まった部分と残りを、それぞれ `backgroundColor` 付きの中身のない `Box` で描く。中身のない `Box` の高さは、行の stretch で付く。これは desktop と terminal の両方で見て確かめた。

上下の行のバーは、そのままだとくっつく。desktop では、バーの外枠に `paddingY={0.25}` を付けると、帯の高さを変えずに 2 本に分かれる。

`paddingY` には数値しか渡せない。型定義の `Space` は `"xs"` のような step 名を受け付けると書いているが、engine は `Box prop "paddingY" must be a finite number within 10000` で拒否する。

## terminal では Box のバーがくっつく

terminal で同じ Box レイアウトを描くと、上下のバーがくっつく。`paddingY={0.25}` を付けても、すき間はできない。文字の `█` は行の高さいっぱいまでは塗られないので、文字で描くと自然にすき間ができる。

このため、描き方を全 surface で統一すると terminal の見た目が悪くなる。desktop の列ずれを直す時は、`e.surface === 'desktop'` の時だけ Box レイアウトで描き、terminal は文字のバーのまま残す。

## 未確認

- terminal で `paddingY={0.25}` がどう扱われるか。帯の高さが変わらず、すき間も出ないことから 0 に丸められたと推測しているが、engine の挙動は確かめていない。
- desktop app が `mono` を拒否する理由。
