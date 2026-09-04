# Git 署名検証の設計

- Date: 2026-09-04
- 出典: `man git-config` の `gpg.ssh.allowedSignersFile` / 実機 git 2.55.0 で allowed_signers の 1 行を変えて `%G?` を取った比較（2026-09-04） / 実機 `chezmoi apply`（v2.72.1）後の `git log --show-signature`（2026-09-04）

手元で自分の commit の署名を検証できるようにした構成の理由を残す。**GitHub 上の Verified 判定はこの設定と関係しない。** そちらは GitHub に登録した signing key で検証される。

## allowed_signers を chezmoi template から作る理由

`config.tmpl` の `user.signingkey` と同じ `op://Personal/GitHub Signing Key/public key` を正本にする。手で置くと、鍵を差し替えた時に片方だけ古くなる。生成にすれば `chezmoi apply` が両方を同時に更新する。

principal（email）だけは `config.tmpl` と `allowed_signers.tmpl` に literal で重複する。1 箇所へ寄せるには `.chezmoidata` を足すことになり、値 1 つのために置き場が増える。両方のテンプレートのコメントで結び付けている。

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

## 実測: 未検証が 41 件残る

`main` の 508 commit のうち 467 件が `G`、41 件が `N`（2026-09-04）。`N` は 2026-08-31 から 09-02 の commit で、署名そのものが付いていない。allowed_signers を置いても変わらない。`archive/pre-reset-20260827` は 370 件すべて `G`。
