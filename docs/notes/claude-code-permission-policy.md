# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、`ask` を置かず、`deny` を必要最小限に保つ。`allow` は read-only subagent の起動許可に限って置く。

## 方針

- `allow` は `Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` だけに置き、workflow 上必要な read-only subagent の起動を追加確認なしにする（ADR 0033 / 0035）。tool 実行や停止線の判断は別に維持する。
- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- `~/.ssh/**`、`~/.aws/**`、`~/.config/gh/**` など home credential store は `~/` anchor で止める。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。
- package publish、deploy、release、push は settings で個別網羅せず、既定 prompt、専用 workflow、sandbox / network policy、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。

## 根拠

- Claude Code permissions docs では、`Read(//**/.env)` は filesystem-wide `.env` に match する。
- arbitrary subprocess の file read は permissions だけでは覆えないため、home credential store は sandbox `denyRead` / `denyWrite` でも守る。
