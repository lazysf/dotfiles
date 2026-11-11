# 残タスク

- Date: 2026-11-11

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## Claude Code で macOS の識別子検査を確認する

- 記載: 2026-11-11（Codex で macOS の sh 回帰検査と配布先の実行を確認した作業）

Codex での macOS 検証は完了。実測は [git-commit skill の設計](docs/notes/git-commit-skill-design.md#codex-の-os-ごとの識別子検査) にある。Claude Code の session でも次を確認する。

- [ ] **sh 回帰検査**。`sh scripts/tests/check-identifiers.tests.sh` の 10 ケースを実機で通す。配布済み `~/.claude/skills/git-commit/scripts/check-identifiers.sh` でも同じ 10 ケースを通す。診断の識別子漏えい防止と、`diff.ignoreSubmodules=all` 下の staged gitlink の path 検査を含む。
- [ ] **配布先での実行**。Claude 側 sh の managed path と target の実体を突き合わせ、正本との一致を確認する。Claude Code の sandbox 内で配布済み sh を読み取り、stage なし・識別子なしで exit 0、識別子ありで exit 1、存在しない script path で非ゼロ終了になることを確認する。診断に実際の home・user・host が含まれないことも確認する。
