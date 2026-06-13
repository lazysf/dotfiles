# 0014: RTK を Codex shell proxy として採用する

- Status: Superseded
- Superseded-By: 0015

## Context

`rtk init -g --codex` は live 側の `~/.codex/AGENTS.md` に `~/.codex/RTK.md` への参照を追加し、shell command を `rtk` 経由で実行する指示を導入する。
この指示は Codex の runtime behavior に影響するため、live 環境だけに置くと `chezmoi apply` や別端末展開で再現されない。

## Decision

RTK を共通 Codex ハーネスの deployable runtime surface として採用する。
`dot_codex/RTK.md` を deployable artifact として管理し、`dot_codex/AGENTS.md` から展開先 home directory に合わせた薄い参照だけを置く。
`dot_codex/RTK.md` の本文は `rtk init -g --codex` が生成した内容を維持し、repo 固有の運用境界は ADR と既存の rule 設計で扱う。

## Consequences

- shell command の既定導線は `rtk` 経由になり、出力圧縮による runtime context cost 削減を狙える。
- `AGENTS.md` 本文へ RTK の詳細を展開せず、ADR 0006 の「薄い surface 案内」を維持する。
- `~/.codex/RTK.md` への参照は chezmoi template で生成し、source file に個人 home path を固定しない。
- RTK instruction は prose instruction であり、`dot_codex/rules/` 配下の機械的な `Rule` とは区別する。
- ハーネス運用上、`rtk` は sandbox、approval、破壊的操作、secret handling の境界を変更するものとして扱わない。
- broad な `rtk` allow rule は作らず、承認判断は既存 rule と内側の実コマンド単位で扱う。
- RTK 自体の未導入、DB 初期化、command 互換性の問題は、通常の検証入口や `rtk proxy <cmd>` で切り分ける必要がある。
