# 0043: 現行 Claude 設定から Codex surface を再導入する

- Status: Accepted
- Supersedes: 0042

## 背景

Claude 設定の Codex 向け移植が必要になった。ユーザーは repo 内の `dot_codex/` に移植版を作成する方針を承認した。旧 surface の復元では、現行 Claude の skills と review 手順の変更を取り込めない。

## 決定

現行 `dot_claude/` の契約、skills、reviewer、Caveman を Codex 向けに移植する。Claude 固有の tool と frontmatter は Codex の機能に合わせる。認証情報の deny を持つ permissions profile と、sandbox 外のディスク操作を禁止する rules を管理する。

実機の `config.toml` を丸ごと取り込む案は採らない。通知、MCP、plugin、アプリ設定に作業機固有の値が含まれるため、移植設定と分けて扱う。実機へ適用する際は既存設定の統合を必要とする。

## 影響

Claude 単独という 0042 の方針を置き換える。0042 が退役させた過去の ADR は退役状態を維持する。旧 Codex の skills / agent 構成や厳密な両 surface 対称性は復活させない。共通の意図を保ち、runtime 固有の差を各 surface に残す。

`~/.codex/skills/` での発見は Codex CLI 0.160.0 で確認した。公式の user skill 配置との差は README に記載する。permissions は上書き可能な既定設定であり、管理者による bypass 禁止の強制は扱わない。
