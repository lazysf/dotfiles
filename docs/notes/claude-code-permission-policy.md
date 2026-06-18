# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、`ask` を置かず、`deny` を必要最小限に保つ。`allow` は read-only subagent の起動許可に限って置く。

## 方針

- `allow` は `Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` だけに置き、workflow 上必要な read-only subagent の起動を追加確認なしにする（ADR 0033 / 0035）。tool 実行や停止線の判断は別に維持する。
- subagent ごとの read-only 強制は subagent 定義の `tools` で表現する。`researcher` は `Read, Glob, Grep` のみで純粋 read-only。`quality-reviewer` / `security-reviewer` は `Read, Glob, Grep, Bash` を持つが、Bash は Claude Code built-in read-only command（read-only forms of git、`ls`、`cat`、`grep` 等）と session 全体の既存 deny rule の範囲で実質 read-only として運用し、write 系操作は subagent 契約として実行しない（ADR 0038）。
- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- home credential store は `~/` anchor で止める。現状の対象は `~/.ssh/**`（SSH key）、`~/.aws/**`（AWS credential）、`~/.config/gh/**`（GitHub auth）、`~/.gnupg/**`（GPG key）、`~/.kube/**`（Kubernetes config）、`~/.docker/config.json`（registry auth）、`~/.netrc`（HTTP auth）、`~/.npmrc` / `~/.pypirc`（package registry token）。新規 credential store を見つけたら追加する。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。external network CLI は exfil 経路として `curl` / `wget` / `nc` を明示 deny する。`ssh` / `scp` / `rsync` などの通常運用 network CLI は deny しない。sandbox `network.allowedDomains` で許可ホストを絞り、それ以外の外部送信は block + LLM 契約と停止線で受ける。
- reviewer subagent の Bash 契約（write 系を実行しない）の強制力は LLM 遵守依存のため、深層防御として exfiltration 経路（`Bash(git remote set-url *)` / `Bash(git remote add *)`）を `deny` で塞ぐ。`git commit *` / `git push *` 等の write 系 git は main session の `git-commit` / `git-push` skill が使うため deny 不可、契約 + Claude Code default prompt（built-in read-only set 外は prompt） + sandbox で防御する。
- package publish、deploy、release、push は settings で個別網羅せず、既定 prompt、専用 workflow、sandbox / network policy、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。

## 根拠

- Claude Code permissions docs では、`Read(//**/.env)` は filesystem-wide `.env` に match する。
- arbitrary subprocess の file read は permissions だけでは覆えないため、home credential store は sandbox `denyRead` / `denyWrite` でも守る。
