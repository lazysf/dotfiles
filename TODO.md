# 残タスク

- Date: 2026-09-04

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. 打ち切り順の reviewer 指摘（5 件）

- 記載: 2026-09-01（coding-standards への打ち切り順の導入）

打ち切り順を入れた時の review で non-blocking とされた分のうち、未対応の 5 件。

**2026-09-02 の分割で前提が変わった指摘がある。** 打ち切り順は当時の `rules/coding-standards.md` から `skills/coding/SKILL.md` へ移り、品質の優先順位・基本原則・最小差分は `dot_claude/CLAUDE.md` に統合された。「段 1 が YAGNI とほぼ同文」は別ファイルへの分離で性質が変わり、「新節だけ書式が浮く」は skill 全体の構成が変わっている。着手前に各指摘が今も成立するか見る。

### security-reviewer

**節内の語衝突。** `dot_claude/skills/coding/SKILL.md` の「最初に成立した段で止まる」（= その段で実装に入れ）と「停止線に従って確認する」（= 実装せず人へ）が、同じ番号付きリスト内に同居している。節名を「実装前の打ち切り順」へ rename して他所からの参照は分離したが、節を上から読む経路には残る。reviewer は実害小と判断。

### quality-reviewer

- **段 1 が YAGNI とほぼ同文。** 「未確定の将来要件なら作らない」が同ファイルの基本原則と重複する
- **段 6 と段 7 の境界が薄い。** 段 7「依頼を満たす最小の実装」が既に実装量の最小化を含むため、段 6 が独立して効く場面が読み取りにくい。「最初に成立した段で止まる」の「止まる」も、段 1-5 では打ち切りだが段 6-7 では結局書くので性質が違う
- **新節だけ書式が浮く。** 他の節は bullet 中心、打ち切り順は番号リスト + 地の文 4 段落。常時 load の rule で地の文が続くと読み飛ばされやすい
- **段 4 の例が web 寄り。** `<input type="date">`、CSS、DB 制約はこの repo の言語構成に当たらない

---

## 2. `gpg.ssh.allowedSignersFile` が未設定

- 記載: 2026-09-01（GitHub アカウント再作成に伴う git identity 移行）

設定されておらず、ファイルも存在しない。このため手元では署名を検証できない。

```text
error: gpg.ssh.allowedSignersFile needs to be configured and exist for ssh signature verification
```

`git log --show-signature` や `%G?` が自分の commit を未検証（`N`）と表示する。**GitHub 上の Verified 判定には影響しない**（そちらは GitHub に登録した signing key で検証される）。

設定する場合は、署名鍵と identity の対応を書いたファイルを用意して `gpg.ssh.allowedSignersFile` から指す。鍵は 1Password の `GitHub Signing Key` を正本とするため、`dot_config/git/config.tmpl` と同じく template から生成するか、`config.local` 側に置くかの選択がある。

---

## 3. 削除済み notes 内の commit リンクが解決しない

- 記載: 2026-09-01（GitHub アカウント再作成に伴う git identity 移行）

`docs/notes/model-and-effort-tuning-history.md` に、commit を指すリンクが 5 本ある。

このファイルは既に retire 済みで、現在の tree には存在しない。履歴の中にのみ残る。リンクの URL は所有者名を新アカウントへ置換したが、**指している commit SHA は履歴書き換えで変わっており、解決しない**。

現在の doc としては壊れていないため実害は無い。直すなら履歴の書き換えが必要で、費用対効果は低い。

---

## 4. `archive/pre-reset-20260827` が未 push

- 記載: 2026-09-01（GitHub アカウント再作成に伴う git identity 移行）

ローカルにのみ存在する。identity と署名は `main` と同じ基準へ揃えてあり、旧アカウント名も旧アドレスも含まないため、公開しても問題は無い。

送る場合は次を実行する。

```bash
git push -u origin archive/pre-reset-20260827
```

送らない判断もあり得る。`main` の祖先なので、履歴そのものは `main` 側に残っている。

---

## 5. disk 以外の破壊 command が deny に無い

- 記載: 2026-09-02（disk 破壊 deny の macOS 追従、`security-reviewer` の non-blocking 指摘）

`permissions.deny` が名前で挙げているのは `mkfs` 系 / `newfs_` 系 / `diskutil` だけ。2026-09-02 に実在を確認した未 deny の破壊系は次のとおり。

`dd` / `fdisk` / `gpt` / `asr` / `hdiutil` / `pdisk` / `apfs_hfs_convert` / `fsck_apfs` / `fsck_hfs` / `nvram` / `bless` / `csrutil` / `tmutil`。

reviewer は `tmutil`（Time Machine backup の削除）の期待損失が disk format より大きい可能性を挙げている。

**ただし名前を足しても境界は動かない。** 理由は `docs/notes/claude-code-settings-design.md` の「sandbox で効いている層と効いていない層」に書いてある。deny は名前ベースで `sudo` / 絶対パス / `sh -c` を覆わず、実効的な層は別にある。`dd` は引数順が自由なため、`Bash(dd *)` で全 dd を止めない限り prefix match では捕まらない。

着手前に「この層に何を期待するか」を決める必要がある。事故と model の誤りへの speed bump と割り切るなら名前を増やす価値はあるが、境界として数えるなら別の層（hook など）が要る。

---

## 6. chezmoi source の `settings.json` が protected path でない

- 記載: 2026-09-02（disk 破壊 deny の macOS 追従、`security-reviewer` の non-blocking 指摘）

sandbox が書き込みを止めるのは `~/.claude/settings.json` と `<repo>/.claude/settings.json` という**名前**。chezmoi source の `dot_claude/settings.json` は作業ディレクトリ配下の別名なので、この保護に入らない。sandbox 内の command が書き換え、`chezmoi apply` で `~/.claude/settings.json` へ昇格できる。

つまり `dot_claude/settings.json` に書いた rule は、事故と model の誤りへの guardrail であって、侵害されたプロセスに対する境界ではない。

**書き込みが通ることは確認済み。** session へ渡される sandbox 設定の write deny 一覧に `<repo>/.claude/settings.json` は入っているが `<repo>/dot_claude/settings.json` は入っておらず、2026-09-02 にこの経路で実際に編集した（disk 破壊 deny の変更そのもの）。

---

## 7. `lapidary` に出力の秘密情報規定が無い

- 記載: 2026-09-03（`lapidary` の自動発火化、`security-reviewer` の non-blocking 指摘）

`dot_claude/skills/git-commit/SKILL.md` は「エラー全文をそのまま貼らない。`git` の出力には認証 URL や token が混ざることがあり、報告に残すと秘密情報が履歴に残る」を持つ。`lapidary` に対応する規定が無い。

この skill は毎回 diff 全体を読み、確認内容を出力する。自動発火へ変えたことで実行回数が増えるため、tracked file に混ざった値を転記する経路が広がる。sandbox の deny は `.env` などの read を止めるが、tracked file 内の値は止めない。

実際に転記が起きたかは未確認。規定を足すかどうかは、`git-commit` 側の文言をどこまで一般化できるかと合わせて決める。

---

## 依存関係

5 と 6 はどちらも `dot_claude/settings.json` の防御層をどう位置付けるかの話だが、5 は rule の中身、6 は rule を置くファイル自体の保護で、別々に閉じられる。
