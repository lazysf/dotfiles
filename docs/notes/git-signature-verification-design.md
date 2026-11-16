# Git 署名検証の設計

- Date: 2026-11-06
- 出典: `man git-config` の `gpg.ssh.allowedSignersFile` / 実機 git 2.55.0 で allowed_signers の 1 行を変えて `%G?` を取った比較（2026-09-04） / 実機 `chezmoi apply`（v2.72.1）後の `git log --show-signature`（2026-09-04） / 実機 git 2.56.0 の `git log --format=%G?`（2026-10-22） / 個人の Windows での `git config --show-origin` と `git log --show-signature`（2026-10-22） / `chezmoi managed` に `.github/` が出ないことの確認（2026-10-22） / ruleset 作成時の `gh api` の応答と `GET repos/lazysf/dotfiles/rules/branches/main`（2026-10-22） / エージェント用の鍵で署名した commit の push と、GitHub 上の署名表示（2026-11-06）

手元で自分の commit の署名を検証できるようにした構成の理由を残す。**GitHub 上の Verified 判定はこの設定と関係しない。** そちらは GitHub に登録した signing key で検証される。

## allowed_signers を chezmoi template から作る理由

`config.tmpl` の `user.signingkey` と同じ `op://Personal/GitHub Sign Key/public key` を正本にする。手で置くと、鍵を差し替えた時に片方だけ古くなる。生成にすれば `chezmoi apply` が両方を同時に更新する。

principal（email）は `config.tmpl` の `user.email` と同じ `op://Personal/GitHub/noreply` から読む。repo に literal で書くと、GitHub アカウントを作り直した時に、repo 内の 2 箇所の ID を差し替えることになる。1Password を正本にすれば、差し替えずに済む。

## エージェント用の鍵の行を消した理由

エージェントの commit を専用の鍵で署名していた間は、`allowed_signers.tmpl` が作業機の `~/.ssh/agent_signing_ed25519.pub` を読み、同じ principal でもう 1 行出していた。この構成は 2026-11-16 に廃止し（[エージェントの commit 署名の設計](agent-commit-signing-design.md)）、行も消した。専用の鍵で署名した過去の commit は 1Password の鍵で署名し直すので、手元で検証するための行は残さない。

## 署名を設定するマシン

identity と署名は、`.profile` が `personal` で、OS が macOS か Windows のマシンにだけ設定する。仕事のマシンには 1Password が無いので、`op` の有無ではなく `.profile` で決める。`personal` のマシンで `op` が 1Password へ届かない時は、`onepasswordRead` が展開を止める。

Windows の `gpg.ssh.program` は、1Password の [Git commit signing](https://www.1password.dev/ssh/git-commit-signing/) に載っていない（2026-10-22 確認）。個人の Windows に winget の `AgileBits.1Password` で入れると、`op-ssh-sign.exe` は `%LOCALAPPDATA%\Microsoft\WindowsApps\` に app execution alias として置かれる（2026-10-22、実機で確認）。install 方法が変わって alias が消えた時に、署名できない config を書き出さないよう、見つからなければ展開を止める。alias は reparse point なので、存在の確認は辿らない `lstat` で行う。個人の Windows では、`chezmoi apply` が止まらずにこの path を `gpg.ssh.program` へ書き、`git log --show-signature` が `Good "git" signature` を出す（2026-10-22、chezmoi v2.73.3、git 2.55.0.windows.5）。

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

GitHub はこのファイルを読まない。ファイルを変えただけでは設定は変わらず、ブラウザで手動で反映する。gh は使わない（[gh の認証の設計](gh-authentication-design.md) の冒頭）。

- 新規作成: repo の Settings の左の Rulesets を開き、New ruleset の Import a ruleset から `.github/rulesets/main.json` を読み込む（[Managing rulesets for a repository](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository)、2026-11-16 確認）。
- 更新: 同じ画面で既存の ruleset を開き、ファイルの内容に合わせて編集する。
- 反映の確認: `https://api.github.com/repos/lazysf/dotfiles/rules/branches/main` を開き、`required_signatures` が返ることを見る。public repo なので認証は要らない。

ルールは main へ直接 push する運用に合わせ、PR や status check を要求しない。

ruleset ID 25613758 として反映し、`rules/branches/main` が `required_signatures` を返すことを確認した（2026-10-22）。`bypass_actors` は空で、owner の push にも掛かる。
