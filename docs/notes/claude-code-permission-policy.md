# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、明示 `allow` / `ask` を置かず、`deny` を必要最小限に保つ。

## 方針

- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- `~/.ssh/**`、`~/.aws/**`、`~/.config/gh/**` など home credential store は `~/` anchor で止める。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。
- package publish、deploy、release、push は settings で個別網羅せず、既定 prompt、専用 workflow、sandbox / network policy、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。

## 根拠

- Claude Code permissions docs では、`Read(//**/.env)` は filesystem-wide `.env` に match する。
- arbitrary subprocess の file read は permissions だけでは覆えないため、home credential store は sandbox `denyRead` / `denyWrite` でも守る。
