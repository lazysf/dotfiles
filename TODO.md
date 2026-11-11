# 残タスク

- Date: 2026-11-11

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## Codex の git-commit に識別子の検査を入れる

- 記載: 2026-11-11（Claude Code の `git-commit` skill に `scripts/check-identifiers.sh` を同梱した作業）

- 確認: 2026-11-11

Windows の対応・配布・検証は完了。残りは macOS の実機確認。設計と実測の根拠は [git-commit skill の設計](docs/notes/git-commit-skill-design.md#codex-の-os-ごとの識別子検査) と [Codex harness の運用](docs/notes/codex-harness-operation.md#git-commit-の識別子検査) にある。

- [x] **skill の置き場と呼び方**。公式の user scope は `~/.agents/skills`。この repo の既存配布先 `~/.codex/skills` は維持した。読み込んだ `SKILL.md` の親を基準に script の絶対 path を解決し、専用変数や `~` の展開に依存しない。
- [x] **Windows の sh 起動調査**。`workspace-write`、Windows sandbox の設定値 `mxc` で確認。`sh` は PATH に無く、Git 同梱の `sh.exe` は `0xC0000142` で起動に失敗した。Windows では PowerShell 7 版を使う。
- [x] **Windows の識別子取得と検査**。home・user・host の取得、Windows home の両区切り表記、staged と unstaged の区別、非 UTF-8・UTF-16、診断の匿名化を確認した。Job Object による timeout と子孫の終了も含め、54 ケースが成功した。
- [x] **実装と配布対象**。PowerShell 版と helper、sh 版を Codex skill に同梱した。手順・停止条件・報告条件と notes を更新済み。`chezmoi managed` で配布対象を確認した。共有 sh の修正は Claude Code と prek にも効く。
- [x] **apply 後の Windows 確認**。Codex の script・helper 一式と Claude 側 sh が正本と一致した。対象の `chezmoi status` は差分なし。配布先の Windows 版で 54 ケースが成功した。
- [x] **子セッションでの skill 読み込み**。会話履歴を渡さない子 agent が、初期の skill 一覧から `git-commit` を発見した。更新済みの本文と同梱 script の存在を確認した。独立したアプリ／CLI の再起動確認ではない。
- [x] **組み込みレビュー**。指摘を修正し、再レビューで追加の actionable bug がないことを確認した。実装は `e43388e`、設計・検証記録は `ed58271` で commit 済み。
- [ ] **macOS の sh 回帰検査**。`sh scripts/tests/check-identifiers.tests.sh` の 10 ケースを実機で通す。診断の識別子漏えいがないことと、`diff.ignoreSubmodules=all` 下でも staged gitlink の path を検査することを含む。
- [ ] **macOS の配布先での実行**。apply 後の managed path と target の実体を突き合わせる。Codex の `workspace-write` sandbox 内で配布済み sh を読み取り、stage なし・識別子なしで exit 0、識別子ありで exit 1、存在しない script path で非ゼロ終了になることを確認する。
