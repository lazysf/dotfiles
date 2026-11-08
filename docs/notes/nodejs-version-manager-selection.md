# Node.js version manager に nvm を使う理由

- Date: 2026-10-31
- 出典: [volta-cli/volta #2080](https://github.com/volta-cli/volta/issues/2080) / 候補を入れ替えた commit `02ae800`（nvm→volta）・`c4c4865`（fnm→nvm） / mise、fnm、nvm を使った時のユーザーの報告

macOS と Windows で共通して使う Node.js version manager に nvm を使う理由と、ほかの候補を使わない理由を残す。再検討の時に、同じ調査と試行を繰り返さないため。ADR の 3 条件のうち「覆すコストが高い」を満たさないので、ADR ではなく notes に置く。

## 構成

- macOS: Homebrew の formula `nvm`。`dot_config/zsh/dot_zshrc` で `NVM_DIR="$HOME/.nvm"` を設定し、`${HOMEBREW_PREFIX}/opt/nvm/nvm.sh` を source する。
- Windows: winget の `AuthorSoftware.NVMWindows`（nvm-windows）。

導入は setup スクリプト（`scripts/macos/setup.sh`、`scripts/windows/setup.ps1`）が行う。

## 候補ごとの理由

nvm、mise、fnm の評価は、ユーザーが実際に使った時の報告による。

- **nvm**: 実運用で問題が出ていない。
- **volta**: 2025-11 に end-of-maintenance が公式に告知され、今は保守されていない。メンテナが勧める移行先は `mise`。今は動くが、将来の OS の更新や Node のメジャー更新で壊れるおそれがあり、壊れても修正は出ない。
- **mise**: メモリを圧迫した。
- **fnm**: AI エージェントの非対話 shell から node を使えなかった。
