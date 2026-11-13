# 残タスク

- Date: 2026-11-13

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## gh の 1Password 連携の確認

- 記載: 2026-11-13（gh の token を 1Password から渡す構成の導入）

`docs/notes/gh-authentication-design.md` の「未確認」を、apply の後に確かめる。結果は同じ notes に書く。

- [ ] **mac のエージェントに gh を使わせるか**。sandbox の中では `op` が 1Password の app につながらない（2026-11-13 確認）。使わせるなら、`op` が使う socket を確かめてから、sandbox の `allowUnixSockets` に足すかを判断する。

## skill と契約の見直しで保留したもの

- 記載: 2026-11-11（Claude と Codex の設定と skill の見直し、coding の `paths`、識別子の検査の同梱）

どれも急がない。surface に触れる項目は、着手する時に `AGENTS.md` の「surface を直す時」の確認を通す。

- [ ] **coding の `paths` を残すか判断する**。`paths` を付けた後（2026-11-10 以降）に、コードを編集した session が 10 本たまったら、`docs/notes/coding-skill-design.md` と同じ集計（コードを編集した session のうち、skill が発火した数）で比べる。増えていなければ外す。
- [ ] **Codex の skill の置き場**。公式 docs の user scope は `~/.agents/skills` で、この repo は `~/.codex/skills` に配っている。移すなら、`dot_codex/` の配布先と、Codex の git-commit が呼ぶ script の path も変わる。
- [ ] **lapidary の description を削る**。description に実装の細部が入っている。trigger に効かない部分を落とす。
- [ ] **別の project で、Bash で読み書きしている件**。共通契約は読み書きを Read / Edit / Write に定めているが、別の project の session では Bash で読み書きしていた。契約が効いていない理由を、その session の記録で確かめる。
