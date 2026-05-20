# Git Add Approval Friction Diagnosis

`git add <paths>` が approval や escalation に見えるときは、まず未定義コマンドとしての prompt と sandbox 書き込み失敗を切り分ける。

## 確認できた事実

- 現行の `dot_codex/rules/` には `git-add.rules` と `git-commit.rules` は置かず、`git add` と `git commit` は未定義コマンドとして既定 prompt に任せる。
- explicit-path の `git add` が追加承認付きで再実行された事例では、最初の失敗理由は rule 不一致ではなく次のエラーだった。
  - `fatal: Unable to create '/Users/<user>/.local/share/chezmoi/.git/index.lock': Operation not permitted`
- このケースでは、同じ `git add` コマンドを権限付きで再実行すると成功している。

## 診断のしかた

1. `git add` が止まったら、まず stderr に `.git/index.lock` と `Operation not permitted` が出ていないかを見る。
2. このエラーがある場合は、原因は Git rule ではなく sandbox から `.git/index.lock` を作れなかったこととして扱う。
3. rule 追加を検討するのは、拒否された実コマンド文字列、必要性、影響範囲が確認でき、既定 prompt では運用上不足すると立証できた場合だけにする。

## 運用メモ

- Git rules は読み取り系の最小 `allow` だけで整理し、mutation は既定 prompt と `git-commit` skill の停止線に任せる。
- `git add` の staging 範囲の安全性は、`git-commit` skill の合意済み範囲確認と `git diff --staged` 確認で担保する。
- explicit-path の `git add` friction を見つけても、先に sandbox 失敗を除外しないまま `git-add.rules` を追加しない。
