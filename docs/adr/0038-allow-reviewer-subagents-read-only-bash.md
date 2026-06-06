# 0038: reviewer subagent に read-only Bash を許可し両 surface の fallback を対称化する

- Status: Accepted
- Amends: 0035

## 背景

ADR 0035 / 0036 で両 surface を軽量 LLM-native へ揃え、reviewer subagent はユーザー明示時に対象 diff を呼び出し元（lead）から渡される前提とした。Claude 側の reviewer は `tools: Read, Glob, Grep` だけを持ち、`Bash` を含めないことで「read-only を tools で物理強制する」設計選択を取った（ADR 0035）。

運用上、次の非対称が確認された:

- **Codex reviewer**: `sandbox_mode = "read-only"` で動作。`dot_codex/rules/git-*.rules` で `git status` / `git diff` / `git log` / `git branch -vv` / `git remote -v` を `allow` しているため、lead が明示 diff を渡し忘れても、reviewer が自分で read-only git により diff を取得する fallback が成立する。
- **Claude reviewer**: `tools` から `Bash` を外しているため、明示 diff がない場合は停止するしかなく、lead が再起動する turn コストが発生する。

両 surface とも同じ「ユーザー明示時に diff を review する」役割であるのに、fallback の可否が `tools` 制限の差で揃わない。

Claude Code 公式仕様（[permissions](https://code.claude.com/docs/en/permissions)）では、Bash の built-in read-only set に「read-only forms of `git`」が含まれ、prompt なしで実行される。subagent に `Bash` を含めても、read-only な git 操作は session 全体の既存 deny rule（`Bash(rm -rf /)` 等）と built-in read-only set の範囲で実質 read-only として運用できる。write 系操作（`git add` / `git commit` / `git push` 等）は default で prompt されるため、契約違反は可視化される。

## 決定

Claude 側 reviewer subagent 2 つに read-only Bash を許可し、Codex 側と fallback を対称化する。

- `dot_claude/agents/quality-reviewer.md` と `dot_claude/agents/security-reviewer.md` の frontmatter で `tools: Read, Glob, Grep` を `tools: Read, Glob, Grep, Bash` に変更する。
- 両 reviewer の本文に Codex と対称な fallback を明記する: 「明示 diff が渡されていない場合のみ、read-only で `git status -sb`、`git diff`、`git diff --staged`、quality-relevant / security-relevant な untracked content（`git status -sb` の `??` 行から特定）を確認する」。fallback command 集合は Codex `dot_codex/rules/git-status.rules` / `git-diff.rules` の allow と Claude Code built-in read-only set の両方に整合する形で正規化する。
- 両 reviewer の本文に「write 系操作（`git add` / `git commit` / `git push`、ファイル編集、外部 I/O 等）は責務外として実行しない」と明記する。
- 両 reviewer の停止線を「変更セットも git 状態も確認できない」に揃える（Codex 側と同一）。
- `researcher` は対象外。仕事内容（コード / docs / 設定の調査）に git fallback が不要なため、両 surface とも `tools: Read, Glob, Grep` 相当の純粋 read-only を維持する。
- Codex 側は変更なし（既に fallback あり）。

## 検討した代替案

- **Codex から fallback を削除して Claude に揃える（厳格対称、fallback なし）**: lead が diff を渡し忘れた時に停止 → 再起動の turn コストが両 surface で発生する。実用性が下がるため却下。
- **現状の非対称を維持**: 両 surface の役割が同じであるのに動作差があり、対称化の利点（保守者の認知負荷低減、運用契約の一貫性）が得られないため却下。
- **session 全体で write 系 git を deny rule 化**: `git-commit` / `git-push` skill が main session で動かなくなるため却下。

## 影響

- **両 surface 対称化**: reviewer の動作モデルが完全一致する。lead からの diff 渡しが標準、明示 diff がない場合のみ fallback で git から取得する。
- **物理 read-only 強制の緩和**: Claude reviewer の「tools 制限で物理的に read-only 強制」は緩和され、built-in read-only command と session 全体の deny rule に依存する形になる。Bash 全体は使えるが、built-in read-only command は prompt なし、write 系は default prompt で可視化されるため、実質的な read-only 性は保たれる。
- **researcher は不変**: 両 surface とも `tools: Read, Glob, Grep` のみ。read-only subagent の最小設計を維持。
- **policy 文書追従**: `docs/notes/claude-code-permission-policy.md` に「reviewer は Bash を含むが実質 read-only として運用する」と追記する。実装時に exfiltration 経路の深層防御として `Bash(git remote set-url *)` / `Bash(git remote add *)` を `dot_claude/settings.json.tmpl` の deny に追加した（詳細は同 policy doc）。
- **ADR 0035 の Amend**: ADR 0035 の「researcher から Bash を外す」方針は維持。reviewer の物理 read-only 強制部分のみを本 ADR で更新する。
