# 0047: Codex のエージェント用の鍵での署名をやめる

- Status: Accepted
- Supersedes: 0046

## 背景

ADR 0046 で、macOS の `personal` の Codex がエージェント用の鍵で署名するようにした。Windows にも同じ構成を入れるつもりで調べたところ、`elevated` の sandbox の中から専用の `ssh-agent` に接続できなかった。実測は [Windows の署名とコマンド制限](../notes/codex-harness-operation.md#windows-の署名とコマンド制限) にある。

## 決定

Codex は Windows でも macOS でも、エージェント用の鍵で署名しない。commit の署名は global の Git 設定に任せる。macOS の配布の script は消す。Windows に入れられないので、OS の間で Codex の操作感を揃えるために macOS でもやめる。

Claude Code のエージェント用の鍵での署名は続ける。

## 検討した代替案

- **Windows に同じ構成を移す**: `elevated` は専用ユーザーで動くので、`ssh-agent` の UID の検査で接続を閉じられる。`unelevated` に替えると、読み取りの deny が効かなくなる。
- **named pipe で署名要求を取り次ぐ**: 固定のデータの署名までは通った。`git commit` からの呼び出しは実行ポリシーで止まった。実用にするには、起動できるクライアントと常駐する処理を新しく作って保守することになる。
- **macOS だけ残す**: 動いているが、Codex の commit の操作が OS で変わる。

## 影響

Codex の commit では、1Password の承認が出る想定になる。エージェントの作業がそこで止まる。

source を消しても、apply 済みの mac の `~/.codex` には設定が残る。手で外す手順は [macOS のエージェント用署名](../notes/codex-harness-operation.md#macos-のエージェント用署名) にある。

mac の実機の config には `~/.ssh` の `deny` を残す。mac には Claude Code のためにエージェント用の鍵が残るので、署名をやめても読み取りは止める必要がある。この設定は ADR 0044 のとおり、実機の config で管理する。
