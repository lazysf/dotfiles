# Git 署名検証の設計

- Date: 2026-10-22
- 出典: `man git-config` の `gpg.ssh.allowedSignersFile` / 実機 git 2.55.0 で allowed_signers の 1 行を変えて `%G?` を取った比較（2026-09-04） / 実機 `chezmoi apply`（v2.72.1）後の `git log --show-signature`（2026-09-04） / 実機 git 2.56.0 の `git log --format=%G?`（2026-10-22） / `chezmoi managed` に `.github/` が出ないことの確認（2026-10-22） / ruleset 作成時の `gh api` の応答と `GET repos/lazysf/dotfiles/rules/branches/main`（2026-10-22）

手元で自分の commit の署名を検証できるようにした構成の理由を残す。**GitHub 上の Verified 判定はこの設定と関係しない。** そちらは GitHub に登録した signing key で検証される。

## allowed_signers を chezmoi template から作る理由

`config.tmpl` の `user.signingkey` と同じ `op://Personal/GitHub Sign Key/public key` を正本にする。手で置くと、鍵を差し替えた時に片方だけ古くなる。生成にすれば `chezmoi apply` が両方を同時に更新する。

principal（email）は `config.tmpl` の `user.email` と同じ `op://Personal/GitHub/noreply` から読む。以前は 2 箇所に literal で持っていたが、GitHub アカウントを作り直した時に repo 内の ID を差し替えずに済むよう、1Password を正本にした。

## 実測: 形式のどこが検証を左右するか

git 2.55.0 で allowed_signers の 1 行を変え、直近 commit の `%G?` を取った（2026-09-04）。

| 形 | 結果 |
| --- | --- |
| principal と `namespaces` が正しい | `G` |
| principal を別の address にする | `G`。**git は検証時に principal を照合しない。** ずれるのは `%GS` の表示だけ |
| `namespaces` を書かない | `G`。namespace の制限が消える |
| `namespaces="ssh"` にする | `B`。git は `git` namespace で検証する |

`namespaces="git"` を付ける効果は、この鍵への信頼を git の署名だけに絞ること。検証を通すためではない。

`allowedSignersFile` に書いた `~` は展開される（`HOME` を差し替えて確認）。

## 実測: 全 commit に署名がある

`main` の 551 commit はすべて `G`（2026-10-22、git 2.56.0）。GitHub アカウントの作り直しに合わせて履歴を書き換えた時に、全 commit へ署名し直した。

## GitHub 側で署名を必須にする ruleset

`main` へ push する commit に署名を必須にする設定は、GitHub の repository ruleset で持つ。中身は `.github/rulesets/main.json` を正本にする。

ruleset はこの repo のリモート設定で、home へ配布するものではない。`.` 始まりの path は chezmoi が配布しないので、`.chezmoiignore` に足さずに配布対象から外れる。

GitHub はこのファイルを読まない。ファイルを変えただけでは設定は変わらず、`gh api` で手動で反映する。

```sh
# 新規作成
gh api -X POST repos/lazysf/dotfiles/rulesets --input .github/rulesets/main.json
# 更新（ID は `gh api repos/lazysf/dotfiles/rulesets` で引く）
gh api -X PUT repos/lazysf/dotfiles/rulesets/<id> --input .github/rulesets/main.json
# 反映の確認
gh api repos/lazysf/dotfiles/rules/branches/main
```

ルールは main へ直接 push する運用に合わせ、PR や status check を要求しない。

ruleset ID 25613758 として反映し、`rules/branches/main` が `required_signatures` を返すことを確認した（2026-10-22）。`bypass_actors` は空で、owner の push にも掛かる。
