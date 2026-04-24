# Git Add Approval Friction Diagnosis

`git add <paths>` が approval や escalation に見えるときは、まず rule mismatch と sandbox 書き込み失敗を切り分ける。

## 確認できた事実

- 現行の [git-add.rules](../../dot_codex/rules/git-add.rules) には `pattern = ["git", "add"]` の allow があり、`git add dot_config/yazi/package.toml` は sandbox 内でそのまま成功した事例がある。
- 一方で `git add docs dot_codex scripts/verify_taplo_parser.lua` が追加承認付きで再実行された事例では、最初の失敗理由は rule 不一致ではなく次のエラーだった。
  - `fatal: Unable to create '/Users/<user>/.local/share/chezmoi/.git/index.lock': Operation not permitted`
- このケースでは、同じ `git add` コマンドを権限付きで再実行すると成功している。

## 診断のしかた

1. `git add` が止まったら、まず stderr に `.git/index.lock` と `Operation not permitted` が出ていないかを見る。
2. このエラーがある場合は、原因は Git rule ではなく sandbox から `.git/index.lock` を作れなかったこととして扱う。
3. rule 緩和を検討するのは、拒否された実コマンド文字列が確認でき、その文字列が [git-add.rules](../../dot_codex/rules/git-add.rules) の explicit-path allow と矛盾すると立証できた場合だけにする。

## 運用メモ

- Git rules は最小の `allow` だけで整理し、未定義コマンドは既定 prompt に任せる。
- `git add` は `git-commit` に必要な mutation allow として broad allow にする。
- `git add` の `not_match` や prompt carveout は置かず、staging 範囲の安全性は `git-commit` skill の合意済み範囲確認と `git diff --staged` 確認で担保する。
- explicit-path の `git add` friction を見つけても、先に sandbox 失敗を除外しないまま `git-add.rules` を広げない。
