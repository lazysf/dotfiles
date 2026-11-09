# 0048: Codex の commit は sandbox の外で都度承認する

- Status: Accepted
- Amends: 0047

## 背景

ADR 0047 で、Codex の commit の署名を global の Git 設定に任せた。macOS の global の設定は `op-ssh-sign` で署名する。profile を外した mac の Codex session で sandbox の中から commit すると、`1Password: Could not connect to socket` で失敗した。実測は [macOS のエージェント用署名](../notes/codex-harness-operation.md#macos-のエージェント用署名) にある。

## 決定

Codex の権限は承認ありのモードのままにする。commit に関わる操作は、都度 Codex の承認を受けて sandbox の外で実行する。

Codex の permission profile は mac の実機の config に置かない。ADR 0047 の「mac の実機の config に `~/.ssh` の `deny` を残す」は、この決定で置き換える。

## 検討した代替案

- **profile で 1Password の socket を許可する**: sandbox の中で commit できて、`~/.ssh` の `deny` も残せる。代わりに、以前の profile と同じく network を有効にして、proxy で外向きの通信を止める設定を保守することになる。
- **rule で `git commit` を `allow` にする**: 公式の Rules によると、承認なしで sandbox の外で動く。commit ごとの確認が無くなる。

## 影響

pre-commit などの hook も、承認した commit と一緒に sandbox の外で動く。

mac の Codex の `~/.ssh` の読み取りを profile で止めなくなる。`~/.ssh/config` は読めた。エージェント用の鍵は Claude Code のために mac に残り、パスフレーズが無い。Codex がこの鍵を読めれば、1Password の承認なしで署名できる。この状態を受け入れる。
