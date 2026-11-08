# macOS の 1Password 設定待ちの確認

- Date: 2026-11-07
- 出典: [`scripts/macos/setup.sh` の `wait_for_onepassword`](../../scripts/macos/setup.sh)、擬似端末での検証、ユーザーからの報告

個人用 Mac のターミナルで 1Password の設定待ちだけを実行する手順に対し、ユーザーから想定どおりに動いたとの報告があった。確認の対象は、CLI 連携と SSH agent が未設定の状態から Developer 設定画面を開き、両方の設定が揃うまで待つ経路。

擬似端末で `op`、`ssh-add`、`open` を差し替えた検証では、未設定のまま Enter を押すと再度待つことを確認した。片方を設定すると残りの項目だけを表示した。両方を設定すると先へ進んだ。非対話時の警告と `CHEZMOI=1` での待機のスキップも確認した。
