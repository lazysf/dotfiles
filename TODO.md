# 残タスク

- Date: 2026-11-11

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## 識別子の検査を macOS で確かめ直す

- 記載: 2026-11-11（PowerShell 版の識別子の検査の修正、`684140a`）

`684140a` は PowerShell 版だけを直し、sh 版（`scripts/check-identifiers.sh`）は変えていない。sh 版の test は、名前に `"` を含むファイルを NTFS で作れないため、Windows では走らない。macOS で pull と `chezmoi apply` の後に確かめる。

- [ ] **sh 版の test**。`sh scripts/tests/check-identifiers.tests.sh` が `PASS: 10 shell cases` で終わる。
- [ ] **配布した script を subdirectory から呼ぶ**。使い捨ての repo で、root 側のファイルに `$HOME` を書いて stage し、subdirectory を cwd にして、Claude Code と Codex のそれぞれの sandbox の中から配布先の `check-identifiers.sh` を `sh` で呼ぶ。exit 1 になり、stderr に値が出ない。
