# 残タスク

- Date: 2026-09-04

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. `gpg.ssh.allowedSignersFile` が未設定

- 記載: 2026-09-01（GitHub アカウント再作成に伴う git identity 移行）

設定されておらず、ファイルも存在しない。このため手元では署名を検証できない。

```text
error: gpg.ssh.allowedSignersFile needs to be configured and exist for ssh signature verification
```

`git log --show-signature` や `%G?` が自分の commit を未検証（`N`）と表示する。**GitHub 上の Verified 判定には影響しない**（そちらは GitHub に登録した signing key で検証される）。

設定する場合は、署名鍵と identity の対応を書いたファイルを用意して `gpg.ssh.allowedSignersFile` から指す。鍵は 1Password の `GitHub Signing Key` を正本とするため、`dot_config/git/config.tmpl` と同じく template から生成するか、`config.local` 側に置くかの選択がある。

---

## 2. `archive/pre-reset-20260827` が未 push

- 記載: 2026-09-01（GitHub アカウント再作成に伴う git identity 移行）

ローカルにのみ存在する。identity と署名は `main` と同じ基準へ揃えてあり、旧アカウント名も旧アドレスも含まないため、公開しても問題は無い。

送る場合は次を実行する。

```bash
git push -u origin archive/pre-reset-20260827
```

送らない判断もあり得る。`main` の祖先なので、履歴そのものは `main` 側に残っている。
