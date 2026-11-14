# 残タスク

- Date: 2026-11-14

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## skill と契約の見直しで保留したもの

- 記載: 2026-11-11（Claude と Codex の設定と skill の見直し、coding の `paths`、識別子の検査の同梱）

どれも急がない。surface に触れる項目は、着手する時に `AGENTS.md` の「surface を直す時」の確認を通す。

- [ ] **coding の `paths` を残すか判断する**。`paths` を付けた後（2026-11-10 以降）に、コードを編集した session が 10 本たまったら、`docs/notes/coding-skill-design.md` と同じ集計（コードを編集した session のうち、skill が発火した数）で比べる。増えていなければ外す。
- [ ] **契約の優先の明記が効いたかを確かめる**。2026-11-13 に、harness が shell を勧めても Read / Edit / Write を優先すると契約へ明記した。apply 後の auto mode の session の記録で、`cat`、`sed -n`、heredoc でのファイルの読み書きが減ったかを数える。減っていなければ、PreToolUse hook で止めるかを判断する（`docs/notes/claude-md-design.md` の「tool の使い分けを契約に置く理由」）。
