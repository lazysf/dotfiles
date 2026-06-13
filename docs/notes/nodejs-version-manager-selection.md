# Node.js version manager の選定経緯

- Date: 2026-06-13
- 出典: [volta-cli/volta #2080](https://github.com/volta-cli/volta/issues/2080) / 変遷 commit `02ae800`（nvm→volta）・`c4c4865`（fnm→nvm）

macOS / Windows で共通して使う Node.js version manager を選ぶ際の、各候補の評価と不採用理由を残す。再検討時に同じ調査・試行を繰り返さないため。ADR の 3 条件（特に「覆すコストが高い」）を満たさない選定なので notes に置く。

## 変遷

`fnm` → `nvm` → `volta` → `nvm`（現行）。`dot_config/zsh/dot_zshrc` と setup スクリプト 3 種（`scripts/macos/setup.sh`、`scripts/windows_personal/setup.ps1`、`scripts/windows_work/setup.ps1`）で管理する。

## 各候補の評価

- **volta**: 2025-11 に end-of-maintenance を公式 announce（unmaintained、メンテナ推奨の移行先は `mise`）。今すぐは動くが、放置すると将来の OS update / Node メジャー更新で壊れるリスク。→ 不採用（メンテ終了）。出典: [volta-cli/volta #2080](https://github.com/volta-cli/volta/issues/2080)。
- **mise**: メモリを圧迫する実害が出た（ユーザー実体験による報告）。→ 不採用。
- **fnm**: AI エージェント（非対話 shell）から node を使えなかった（ユーザー実体験による報告）。→ 不採用。
- **nvm**: 実運用で問題なし（ユーザー実体験による報告）。→ 採用。

## 現行構成

- macOS: Homebrew `formula nvm`。`dot_config/zsh/dot_zshrc` で `NVM_DIR="$HOME/.nvm"` を設定し `${HOMEBREW_PREFIX}/opt/nvm/nvm.sh` を source する。
- Windows: winget `CoreyButler.NVMforWindows`（nvm-windows）。
