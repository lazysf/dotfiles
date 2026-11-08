# 残タスク

- Date: 2026-11-08

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. Windows の Codex のエージェント用署名

- 記載: 2026-11-07（Windows の `personal` にエージェント用署名鍵を入れた時）

Windows では Claude Code だけがエージェント用の鍵で署名する。

- Codex の署名設定を入れる `scripts/macos/configure-codex-signing.py` と `run_after_zz-configure-codex-signing.sh.tmpl` は macOS 専用で、zsh のログインシェルを前提にしている。Windows の Codex で同じ鍵を使うなら、Codex の Windows の sandbox と hook の shell を公式情報で確かめてから設計する。
- `dot_codex/rules/destructive.rules` の disk 系の command は macOS のものだけで、2026-11-07 に Claude Code の `permissions.deny` へ足した Windows の command（`diskpart`、`format.com`、`convert.exe`、`wbadmin`）は入っていない。Codex の Windows の sandbox を確かめる時に、揃えるかも判断する。

---

## 2. Windows 実機での動作確認

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

2026-10-22 に、セットアップ済みの個人の Windows で、状態の読み取りと画面の目視で確かめられる項目は確認した。次の項目は、setup の対話実行か新しいマシンが要るので残っている。

個人の Windows で確かめること。

- `scripts/windows/setup.ps1 personal` の日本語の出力が化けない。先頭に UTF-8 の BOM を付けてある。
- 次に署名鍵を新規生成した時、setup が表示する SHA-256 fingerprint が公開鍵と一致する。CLI で登録した場合は、その鍵で署名した commit が GitHub で Verified になることも確かめる。（2026-11-07 追加）
- 引数なしで実行すると、`PromptForChoice` で profile の選択肢が出る。
- 1Password が未設定の時は、Developer の設定画面が開いて待つ。設定すると Enter で先へ進む。`Update-SessionPath` で、winget で入れた `op` が見つかる。設定済みなら待たずに進む。
- `chezmoi init --apply lazysf` で profile を聞かれない。
- 新しいマシンの `chezmoi init --apply` で、`run_onchange_after_install-yazi-plugins.cmd` が plugin を `%USERPROFILE%\.config\yazi\plugins` に入れる。
- Parsec が per computer（`%ProgramFiles%\Parsec`）で入る。管理者でない PowerShell から実行した時に UAC が出て先へ進む。導入後の再実行で `Parsec.Parsec (skip)` になる。VB-CABLE が未導入なら手順が出て公式ページが開き、導入後は `VB-CABLE (skip)` になる。（2026-11-02 追加）
- Parsec の host settings で Fallback To Virtual Display をオンにでき、物理ディスプレイが無い状態で接続すると仮想ディスプレイが出る。`Parsec.ParsecVDD` が `-Scope` 無しの winget で入り、Parsec Virtual Display Adapter が出ることは 2026-11-02 に確認した。（2026-11-02 追加）
- Parsec の host settings で Virtual Mouse をオンにでき、物理マウスが無い状態で接続してもカーソルが出る。`Parsec.ParsecVUD` が `-Scope` 無しの winget で入り、Parsec Virtual USB Adapter が出ることは 2026-11-02 に確認した。（2026-11-02 追加）
- `powershell` から `winget upgrade Microsoft.PowerShell` で PowerShell 7 を更新できる。次の版が出るまで確かめられない。`chezmoi apply` で 7.6.9 の MSIX 版が入り、`pwsh` で profile が読まれて starship と `ls`（eza）が効くことは 2026-11-03 に確認した。（2026-11-03 追加）
- prek の `check-identifiers` hook が動き、値を仕込んだ staged の commit を止める。設計は `docs/notes/markdownlint-and-pre-commit-execution.md` の「作業機の識別子を検査する local hook」にある。（2026-11-08 追加）

仕事の Windows では、`work` を選んだ時に 1Password と Zotero と Parsec が入らず、git の identity と署名の設定が出ないことを確かめる。

---

## 3. Claude Code からの署名鍵の書き込みを制限する

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

承認された書き込みで `~/.ssh/agent_signing_ed25519` の鍵ペアを置かれると、`scripts/macos/setup.sh` と `scripts/windows/setup.ps1` は既存の鍵ペアとして生成をスキップする。その後、README の登録手順で置かれた公開鍵を GitHub に登録するおそれがある。

2026-11-07 に `permissions.deny` へ `Edit(~/.ssh/**)` を、`sandbox.filesystem.denyWrite` へ `~/.ssh` を足した。Windows では sandbox が効かないので、`mv`、`ssh-keygen -f`、`rm` は止まらない（2026-11-07 実測）。mac で止まる範囲と、その実測は `docs/notes/agent-commit-signing-design.md` の「`~/.ssh` への書き込みを止める」にある。残りを塞ぐなら、setup スクリプトが既存の鍵ペアを使う前に確かめる形などを検討する。

---

## 4. Windows の Claude Code で sandbox が担う防御の代わりを確かめる

- 記載: 2026-11-07（今日の commit の security review で範囲外とした項目）

native Windows では、Claude Code の Bash が sandbox の外で動く。mac で sandbox が担っている次の 3 つが、Windows で何に止められるかは確かめていない。前提は `docs/notes/claude-code-settings-design.md` の「Windows では sandbox の防御が効かない」にある。

- エージェントの session からの push がどこで止まるか。mac では、sandbox の proxy が SSH を運ばないので止まる。Windows で見るのは、`core.sshCommand`、1Password の承認がどの範囲まで記憶されるか、gh の credential helper の 3 つ。
- エージェントの Bash が、`mv` や python で `~/.claude/settings.json` や hook を書き換えられるか。mac では protected paths が止める（`~/.claude/settings.json` は 2026-11-07 に実測）。Windows の `~/.ssh` では、同じ形の `mv` と `ssh-keygen -f` が通った（2026-11-07 実測）。
- 大文字で書いた `~/.SSH/...` が、`Edit(~/.ssh/**)` と `Read(~/.ssh/**)` の rule を外れるか。Windows の file system は既定で大文字と小文字を区別しないので、rule を外れると同じファイルに届く。

---

## 5. `CLAUDE.md` の常時発火する義務を条件付きにする

- 記載: 2026-11-07（対応が過剰になるという相談で、原則に「必要なことを、必要な分だけ、必要な時に」を足した時）

`dot_claude/CLAUDE.md` には、依頼の大小に関係なく毎回発火する義務が 2 つ残っている。doc 節と review は同じ時に条件付きにした。新しい原則だけで過剰さが残るかを運用で見て、過剰さが残った義務から順に、判定できる条件へ書き換える。

- 原則の「変更前に関連ファイル、設定、既存パターン、検証入口を確認する」
- 原則の「引き継ぎや完了報告では、変更内容、根拠、検証結果、未確認事項を分ける」

条件に「大きな変更の時」のような主観語は使わない。どの義務も過去の失敗への対策なので、`docs/notes/claude-md-design.md` の対応する節を読み、その失敗の場面を条件の内側に残す。「変更前の確認」では、停止線（認証認可、権限、秘密情報など）に当たるかの確認も内側に残す。

---

## 6. markdownlint の依存に残る npm audit の警告

- 記載: 2026-11-08（tombi の導入で npm audit を見た時）

markdownlint-cli2 を 0.22.1 から 0.24.0 に上げると、`npm audit` の警告は 8 件から 5 件（high 3、low 2）に減った。残る 5 件は 2 つの package から来ていて、どちらも markdownlint 0.42.0 の依存にある。

- `re2js` 2.8.6: 0.24.0（markdownlint 0.42.0）で新しく依存に加わった。markdownlint が完全固定している。修正版は 2.9.1 以降。
- `katex` 0.16.47: 上げる前から入っている。`micromark-extension-math` が `^0.16.0` を要求し、修正版は範囲の外にある。

npm の `overrides` で強制はしない。markdownlint が想定しない組み合わせで動かすことになるため。markdownlint の新しい版が出たら、`npm update` と `npm audit` で解消したかを見る。prek の hook 環境にも同じ版が入るので、`rev` を上げた後の hook 環境も見る。7 の rumdl へ移れば、この項目は消える。

---

## 7. Markdown の lint の見直し

- 記載: 2026-11-08（6 の audit の警告を見て、markdownlint 以外の lint を相談した時）

2 つの候補を試す。どちらも未検証。

- [rumdl](https://github.com/rvben/rumdl) で markdownlint-cli2 を置き換える。Rust 製で、rule 名は markdownlint と同じ `MD001` 形式。公式の pre-commit hook がある。Node の依存が消えるので、6 の警告も消える。試す時は、今の `.markdownlint-cli2.jsonc` を読めるか、repo 全体で判定が markdownlint と揃うか、VS Code の拡張があるかを確かめる。
- [textlint](https://github.com/textlint/textlint) と [`textlint-rule-preset-ja-technical-writing`](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) を併用する。markdownlint が構造を見るのに対し、こちらは日本語の文章を見る。preset の既定は厳しめなので、まず repo 全体での違反の件数を数え、残す rule を選ぶ。

---

## 8. MD024 を入れ直すか判断する

- 記載: 2026-11-08（`docs/notes/` を整備した時）

`.markdownlint-cli2.jsonc` は MD024 を無効にしているが、無効のままにする理由は anchor link が増えて成り立たなくなった。件数、入れ直す時の形、その理由は `docs/notes/markdownlint-and-pre-commit-execution.md` の「MD013 / MD024 を無効化している理由」にある。7 で lint を置き換える場合は、置き換えた先の同じ rule で判断する。

---

## 9. Codex 側の追従

- 記載: 2026-11-08（Claude 側の開発フローを公式の Best practices と照らして直した時）

Claude 側（`dot_claude/`）に入れた次の変更を、`dot_codex/` にも同じ意図で入れるかを判断する。tool 名、配置、権限、hook の仕組みのような runtime 固有の差は、機械的に揃えない（`AGENTS.md`）。

- 規則文の太字を外す（`a4cfae2`）。基準は `docs/notes/harness-design-principles.md` の「規則文に太字を使わない」。根拠は Claude Code の公式ページなので、Codex の公式情報でも同じことが言えるかを確かめる。
- lapidary の目的の文を「直す価値のある不足と過剰を直す」にする（`36efe8a`）。
- git-commit の手順 2 で、commit の範囲に lapidary を通したかを確かめる（`0546bb2`）。
