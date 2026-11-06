# 0046: macOS の Codex 署名設定を chezmoi で追加する

- Status: Accepted
- Amends: 0044

macOS の `personal` では、Codex がエージェント専用鍵を使うための設定を `chezmoi apply` で追加する。署名に必要な設定だけを Codex の `config/batchWrite` で反映する。既存の設定と競合する場合は更新を止める。ファイル全体を配布する案では、既存の Codex 設定を保持できないため採用しない。

公開鍵と socket のパスは展開先で決まる。hook の信頼登録は Codex CLI の `/hooks` で行う。設定と検証の手順は [Codex harness の運用](../notes/codex-harness-operation.md#macos-のエージェント用署名)に置く。
