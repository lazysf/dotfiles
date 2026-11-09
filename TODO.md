# 残タスク

- Date: 2026-11-09

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業で扱う目的は 1 つにする」「作業中に見つけた無関係の問題は、直さずにユーザーへ伝える」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。項目はテーマごとに並べる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

## Windows での進め方

1〜2 は、個人の Windows で、この repo を cwd にした Claude Code の session に「TODO を実施して」と頼めば進められるように書いてある。agent は次に従う。

- 1 項目ずつ進める。項目に入る前に、agent が実行するコマンドと、ユーザーに頼む操作を並べて示し、確認を取る。
- Windows の Bash は sandbox の外で動く。実在の鍵、`~/.claude/settings.json`、hook、`~/.config/git/start-signing-agent` の中身を変えない。書き込めるかを試す時は、控えを `$TMPDIR` に取って同じ内容で上書きし、前後のハッシュが一致することを確かめる。試しに作るファイルは名前を `claude-probe-` で始め、終わったら消す。
- push しない。`--dry-run` も打たない。
- UAC、GUI の操作、対話の選択、機器の抜き差しが要る手順は、agent が実行しない。ユーザーに手順と見てほしいものを示し、結果を聞く。
- 「条件を待つ」に挙げた確認は、条件が揃うまで飛ばして TODO に残す。
- 結果は項目ごとの「書き先」に、日付、版（Claude Code、Git for Windows、prek、Codex など）、確かめ方を付けて書く。確かめ終えた行は TODO から消す。ユーザー名、ホスト名、鍵の fingerprint の値は書かず、一致したかだけを書く。
- 設計が要る項目は、調べた結果と案を示して止まる。実装はユーザーの判断を待つ。

---

## 1. Windows の Codex の確認

- 記載: 2026-11-07（Windows の `personal` にエージェント用署名鍵を入れた時）
- 書き先: `docs/notes/codex-harness-operation.md`

Codex はエージェント用の鍵で署名せず、commit は sandbox の外で都度承認する（[ADR 0047](docs/adr/0047-stop-codex-agent-signing.md)、[ADR 0048](docs/adr/0048-approve-codex-commits-outside-sandbox.md)）。この項目は設計なので、agent は案を示して止まる。CLI の版、`execpolicy check` の照合、公式 docs を調べた結果は [Windows の署名とコマンド制限](docs/notes/codex-harness-operation.md#windows-の署名とコマンド制限) にある。

- ユーザー: Windows の Codex の session で、承認を受けて sandbox の外で使い捨ての repo に commit させる。1Password の承認が出るかと、`git log -1 --format='%G? %GK'` の結果を agent に伝える。
- ユーザー: 通常の権限で開いた Codex の session で、実際のユーザーの `~/.ssh/claude-probe-missing` を PowerShell から読ませる。拒否か「無い」かと、実効の sandbox と profile を伝える。「無い」だけでは既存ファイルの読み取り可否は分からない。確認が必要なら承認を得て、秘密を含まない既存の検証用ファイルで確かめる。
- agent: sandbox 内から外向き通信が止まるかを確認する方法をユーザーと決める。push と `--dry-run` は「Windows での進め方」に従う。
- agent: 無害なコマンドを対象にした一時 rule で、新しい Codex session の PowerShell 経由の実行が止まるかを確かめる。`~/.codex/rules/` に書く前に確認を取る。この結果をもとに、`dot_codex/rules/destructive.rules` に Windows の disk 系（`diskpart`、`format.com`、`convert.exe`、`wbadmin`）と `git push` の禁止を足すか決める。

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
