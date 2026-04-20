# Project との接続

共通ハーネスは `~/.codex` に置き、project-specific knowledge は各プロジェクトで管理します。

## 推奨構成

- `~/.codex/`
  - 共通ハーネス
- `<project>/AGENTS.md`
  - 短い project-local ポインタ
- `<project>/docs/`
  - project-specific knowledge の正本

## Project ルート `AGENTS.md` の役割

- project の目的や制約を短く示す
- 詳細を `./docs/` のどこで読むか案内する
- 共通ルールは home 側の `~/.codex/AGENTS.md` に従う前提を置く

## `docs/` に置くもの

- 設計メモ
- ADR
- 運用手順
- リポジトリ固有の制約
- 参照させたい背景知識

## 避けること

- project-specific knowledge を共通ハーネスへ混ぜる
- project-local knowledge の正本を `.codex/` に置く
- ルート `AGENTS.md` を長い説明書にする
