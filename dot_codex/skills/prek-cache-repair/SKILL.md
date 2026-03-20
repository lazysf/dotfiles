---
name: prek-cache-repair
description: prek や pre-commit 実行時の warning を、壊れた hook cache・欠落した .prek-hook.json・参照切れの Python toolchain という観点で切り分けて復旧する。ユーザーが prek warning の原因調査、cache clean/gc/prepare-hooks の実施、再発確認を求める場合に使用する。
metadata:
  short-description: prek cache 復旧
---

# Prek Cache Repair

`prek` の warning を、事実ベースで切り分けて安全に解消する。

## このスキルを使う場面

- `git commit` や `prek run` で `Skipping invalid installed hook` が出る
- `.prek-hook.json` が見つからない warning が出る
- `Failed to query Python info` が出る
- Python 更新後に `prek` の挙動が不安定になった
- `prek cache clean` すべきか、`gc` だけで十分か判断したい

## 目的

- warning の原因を「事実」と「仮説」に分けて整理する。
- 壊れた hook cache だけを安全に除去する。
- 必要なら `prek` の cache を再構築する。
- 復旧後に warning が消えたことを確認する。

## 対象外

- `.pre-commit-config.yaml` 自体のポリシー変更
- hook 定義の追加・削除そのもの
- `prek` ではなく `pre-commit` 本体の設定移行

## レビュー・改善サイクル（必須）

- 生成・修正する内容（調査結果、対処方針、実行手順、変更案など）は、提示または適用前にレビューする。
- レビュー結果を反映して改善し、これを3回繰り返す。
- 3回目の改善結果を最終案として採用し、ユーザーには最終案のみ提示する。

## 事実確認の順序

### 1) 症状の確認

- warning の全文を確認する。
- どのコマンドで出たかを確認する。
- warning のパス、hook id、toolchain パスを控える。

### 2) 設定の確認

- `.pre-commit-config.yaml` を読む。
- 現在本当に必要な hook が何かを整理する。
- `prek --version` と `which prek` を確認する。

### 3) cache 実体の確認

- `~/.cache/prek/hooks` の一覧を見る。
- warning に出た env ディレクトリの中身を確認する。
- `.prek-hook.json` の有無を確認する。
- `pyvenv.cfg` と `bin/python*` の参照先を確認する。

### 4) 参照切れの確認

- `.prek-hook.json` の `toolchain` を確認する。
- `bin/python` のシンボリックリンク先が存在するかを確認する。
- Homebrew や uv の Python 実体が今もあるか確認する。

## よくある原因

- cache 内の env は残っているが `.prek-hook.json` だけ欠けている
- env 内の `bin/python` が、既に削除された Python 実体を指している
- Python の更新後に、古い hook env が stale cache として残っている
- `prek` の cache 走査時に、未使用の壊れた env が warning を出している

## 推奨ワークフロー

### A. まず安全確認だけしたい場合

1. `prek cache gc --dry-run`
2. warning に出た env が `Would remove ... hook envs` に入るか確認する
3. 入るなら「未使用の壊れた cache」の可能性が高いと判断する

### B. 最小限で片付く場合

1. `prek cache gc`
2. その後 `prek run --all-files`
3. warning が消えれば終了

### C. 壊れた env が複数ある、または参照切れが広い場合

1. `prek cache clean`
2. `prek prepare-hooks`
3. `prek run --all-files`

`cache clean` は再構築コストがあるが、stale cache をまとめて解消しやすい。

## コマンド例

```bash
sed -n '1,260p' .pre-commit-config.yaml
ls -la ~/.cache/prek/hooks
find ~/.cache/prek/hooks -maxdepth 2 -name .prek-hook.json -print
ls -la ~/.cache/prek/hooks/<hook-env>
cat ~/.cache/prek/hooks/<hook-env>/.prek-hook.json
cat ~/.cache/prek/hooks/<hook-env>/pyvenv.cfg
ls -l ~/.cache/prek/hooks/<hook-env>/bin/python*
prek cache gc --dry-run
prek cache gc
prek cache clean
prek prepare-hooks
prek run --all-files
```

## 判断基準

- `.prek-hook.json` がない:
  - 壊れた cache の可能性が高い
- `bin/python` のリンク先が存在しない:
  - 参照切れの Python toolchain
- `gc --dry-run` で回収候補に出る:
  - まず `gc` を優先
- warning が複数種類あり、現在の Python 実体とも食い違う:
  - `cache clean` を優先

## 復旧後の確認

- `prek run --all-files` で warning が出ないこと
- hook が通常どおり `Passed` / `Skipped` になること
- 必要なら次回の `git commit` 時にも再発しないこと

## 注意点

- `prek cache clean` は cache 全削除なので、初回再構築は少し重い
- warning が消えても、`.pre-commit-config.yaml` 自体の誤設定は別問題として残りうる
- 原因を断定する前に、必ず実体パスの存在確認を行う

## 出力フォーマット

```markdown
# デバッグ結果: prek cache warning

## 症状

- [warning の要約]

## 事実と仮説

- 事実:
- 仮説:

## 原因

- [根本原因]

## 修正方針

- [gc / clean / prepare-hooks をどう使うか]

## 実施内容

- [実行したコマンド]

## 検証

- 実施した確認:
- 結果:
- 未検証項目:

## リスク

- [注意点]
```

## 返答のガイド

- まず warning の種類を短く分類する。
- 次に cache 実体の確認結果を事実として示す。
- 対処は `gc` で足りるか、`cache clean` が必要かを分けて提案する。
- 最後に、再発確認の結果を必ず添える。
