# 残タスク

- Date: 2026-11-09

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業で扱う目的は 1 つにする」「作業中に見つけた無関係の問題は、直さずにユーザーへ伝える」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。項目はテーマごとに並べる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

## Windows での進め方

1〜3 は、個人の Windows で、この repo を cwd にした Claude Code の session に「TODO を実施して」と頼めば進められるように書いてある。agent は次に従う。

- 1 項目ずつ進める。項目に入る前に、agent が実行するコマンドと、ユーザーに頼む操作を並べて示し、確認を取る。
- Windows の Bash は sandbox の外で動く。実在の鍵、`~/.claude/settings.json`、hook、`~/.config/git/start-signing-agent` の中身を変えない。書き込めるかを試す時は、控えを `$TMPDIR` に取って同じ内容で上書きし、前後のハッシュが一致することを確かめる。試しに作るファイルは名前を `claude-probe-` で始め、終わったら消す。
- push しない。リモートに届くかは `git ls-remote origin` で見る。
- UAC、GUI の操作、対話の選択、機器の抜き差しが要る手順は、agent が実行しない。ユーザーに手順と見てほしいものを示し、結果を聞く。
- 「条件を待つ」に挙げた確認は、条件が揃うまで飛ばして TODO に残す。
- 結果は項目ごとの「書き先」に、日付、版（Claude Code、Git for Windows、prek、Codex など）、確かめ方を付けて書く。確かめ終えた行は TODO から消す。ユーザー名、ホスト名、鍵の fingerprint の値は書かず、一致したかだけを書く。
- 設計が要る項目は、調べた結果と案を示して止まる。実装はユーザーの判断を待つ。

---

## 1. Windows の Codex のエージェント用署名

- 記載: 2026-11-07（Windows の `personal` にエージェント用署名鍵を入れた時）
- 書き先: `docs/notes/codex-harness-operation.md`。方針が決まったら ADR

Windows では Claude Code だけがエージェント用の鍵で署名する。この項目は設計なので、agent は案を示して止まる。

- agent: Windows に Codex CLI があるかと、その版を見る。Codex の Windows の sandbox、hook を動かす shell、`~/.ssh` を読ませない設定を、公式 docs（`docs/notes/codex-harness-operation.md` の出典）で確かめる。
- agent: mac の `scripts/macos/configure-codex-signing.py` と `run_after_zz-configure-codex-signing.sh.tmpl` は、zsh のログインシェルを前提にしている。Windows に移せるか、移すなら何が要るかを案にする。
- ユーザー: Codex の session で、`~/.ssh` の中の存在しない path（`~/.ssh/claude-probe-missing`）を読ませる。拒否されるか、「無い」と返るかを agent に伝える。後者なら、Windows の Codex は `~/.ssh/agent_signing_ed25519` も読める。
- agent: `dot_codex/rules/destructive.rules` に、Windows の disk 系の command を揃えるかの案を出す。揃える対象は、2026-11-07 に Claude Code の `permissions.deny` へ足した `diskpart`、`format.com`、`convert.exe`、`wbadmin`。Codex の rules が Windows の command 名をどう照合するかを、docs で確かめてから出す。

---

## 2. Windows 実機での動作確認

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）
- 書き先: prek と lint は `docs/notes/lint-and-pre-commit-execution.md` の「未確認」を直す。setup は、README の記述どおりなら TODO から消すだけでよい。食い違ったら、直さずに報告する

2026-10-22 に、セットアップ済みの個人の Windows で、状態の読み取りと画面の目視で確かめられる項目は確認した。

### 条件を待つ

- 新しいマシン（chezmoi の設定ファイルが無く、各ツールが未導入）:
  - 引数なしの `setup.ps1` で、`PromptForChoice` で profile の選択肢が出る。設定ファイルがあると、そこから profile を読むので出ない。
  - 1Password が未設定の時は、Developer の設定画面が開いて待つ。設定すると Enter で先へ進む。`Update-SessionPath` で、winget で入れた `op` が見つかる。
  - `chezmoi init --apply lazysf` で profile を聞かれない。
  - `run_onchange_after_install-yazi-plugins.cmd` が plugin を `%USERPROFILE%\.config\yazi\plugins` に入れる。
  - Parsec が per computer（`%ProgramFiles%\Parsec`）で入る。管理者でない PowerShell から実行した時に UAC が出て先へ進む。VB-CABLE が未導入なら手順が出て公式ページが開く。（2026-11-02 追加）
- 署名鍵を新規生成した時: setup が表示する SHA-256 fingerprint が公開鍵と一致する。CLI で登録した場合は、その鍵で署名した commit が GitHub で Verified になる。（2026-11-07 追加）
- PowerShell 7 の次の版が出た時: `powershell` から `winget upgrade Microsoft.PowerShell` で更新できる。`chezmoi apply` で 7.6.9 の MSIX 版が入り、`pwsh` で profile が読まれて starship と `ls`（eza）が効くことは 2026-11-03 に確認した。（2026-11-03 追加）
- 仕事の Windows: `work` を選んだ時に 1Password と Zotero と Parsec が入らず、git の identity と署名の設定が出ない。

---

## 3. Windows の Claude Code で sandbox が担う防御の代わりを確かめる

- 記載: 2026-11-07（今日の commit の security review で範囲外とした項目）。署名鍵の項目は 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）
- 書き先: `docs/notes/claude-code-settings-design.md` の「Windows では sandbox の防御が効かない」。鍵の件は `docs/notes/agent-commit-signing-design.md` の「Windows では鍵を持ち出せる」

native Windows では、Claude Code の Bash が sandbox の外で動く。mac で sandbox が担っている次の 4 つが、Windows で何に止められるかを確かめる。前提は `docs/notes/claude-code-settings-design.md` の「Windows では sandbox の防御が効かない」にある。

- push がどこで止まるか。mac では、sandbox の proxy が SSH を運ばないので止まる。
  - agent: `core.sshCommand`、`credential.helper`、`gh auth status` を見る。token の値は写さない。
  - agent: Bash で `git ls-remote origin` を実行し、1Password の承認が出るかを見る。出たら、ユーザーは拒否する。
  - ユーザー: 手元の terminal で 1 回承認した直後に、agent がもう一度実行する。承認なしで通るかで、1Password の承認がどの範囲まで記憶されるかを見る。
- agent の Bash が、`~/.claude/settings.json` と hook を書き換えられるか。mac では protected paths が止める（`~/.claude/settings.json` は 2026-11-07 に実測）。
  - agent: 進め方の手順で、同じ内容への上書きを Bash で試す。今の permission mode で、Claude Code が実行前に止めるか、確認を求めるか、そのまま通すかを見る。
- `~/.ssh/agent_signing_ed25519` の鍵ペアを置けるか。これは確かめ済みで、Windows の session では `mv`、`ssh-keygen -f`、`rm` が `~/.ssh` で通った（2026-11-07 実測）。置かれると、`scripts/windows/setup.ps1` は既存の鍵ペアとして生成をスキップし、README の登録手順で、置かれた公開鍵を GitHub に登録するおそれがある。mac で止まる範囲は `docs/notes/agent-commit-signing-design.md` の「`~/.ssh` への書き込みを止める」にある。
  - agent: setup が既存の鍵ペアを使う前に、何を確かめれば置き換えに気づけるかを案にして止まる。
- 大文字で書いた `~/.SSH/...` が、`Edit(~/.ssh/**)` と `Read(~/.ssh/**)` の rule を外れるか。Windows の file system は既定で大文字と小文字を区別しないので、rule を外れると同じファイルに届く。
  - agent: Read ツールで、存在しない `~/.SSH/claude-probe-missing` を読む。拒否されるか、「無い」と返るかを見る。Bash の `ls ~/.SSH` も同じように見る。
  - 外れたら、rule を大文字でも書くかの案を出す。
