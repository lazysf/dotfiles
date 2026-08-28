# 0042: Codex surface を廃止し Claude Code 単独にする

- Status: Accepted
- Supersedes: 0001, 0004, 0006, 0008, 0011, 0013, 0015, 0018, 0019, 0036, 0038

## 背景

ADR 0036 で Codex surface を軽量 LLM-native workflow へ再設計し、両 surface を対称に保つ方針を採った。以降、`skills/`（`git-commit` / `git-push` / `scribe`）、`agents/`（`researcher` / `quality-reviewer` / `security-reviewer`）、運用契約（`dot_codex/AGENTS.md` / `dot_claude/CLAUDE.md`）を両 surface で並列に保持してきた。

対称を保つには、片方を変えるたびにもう片方へ同じ変更を反映する必要がある。実際の運用では Claude Code だけを使っており、この同期コストに見合う利益が出ていない。

## 決定

**Codex surface を廃止し、Claude Code 単独にする。**

- `dot_codex/` を削除する。`AGENTS.md`、`agents/*.toml`、`rules/*.rules`、`skills/`（`caveman` / `git-commit` / `git-push` / `scribe`）が対象。
- root `AGENTS.md` から Codex 固有の参照（Codex Docs、`~/.codex/config.toml`、両 surface 対称の規定）を外す。
- `~/.codex/config.toml` は元から repo の管理外なので、この決定の対象に含まない。
- 「両 surface を対称に保つ」という設計原則そのものを廃止する。

## 検討した代替案

- **両 surface を維持する（ADR 0036 の継続）**: 同期コストを払い続けることになる。Codex を使っていない現状では、対称性から得られる利益が無い。却下。
- **Codex 単独にする**: Claude Code の output style、subagent、sandbox、permission classifier に依存した設計が既にあり、移行コストが廃止コストを上回る。却下。

## 影響

次の ADR は判断の対象そのものが失われたため、本 ADR で `Superseded` にする。各 ADR の本文は採用時点の履歴として保持する（ADR 0022）。

- **0001** (共通 Codex ハーネスは `dot_codex/` に置く): 集約先の `dot_codex/` が存在しない。「deployable artifact と repo-level knowledge を分ける」原則は `dot_claude/` と `docs/` の関係として継続する。
- **0004** (legacy workflow skill prefix を廃止する): 改名・廃止の対象だった `core-*` / `entry-classify` / `phase-*` は Codex の skill 名で、存在しない。再混入を検知する検証スクリプトも ADR 0007 で廃止済み。**「公開する skill 名は prefix なしの kebab-case に統一する」という命名原則は Claude surface へ継承する**（`dot_claude/skills/git-commit` など）。skill の reference file 名も同じ原則で prefix を持たない。
- **0006** (`AGENTS.md` は薄い surface 案内に留める): 対象が `dot_codex/AGENTS.md`。削除済み。薄さを保つ原則は root `AGENTS.md` と `dot_claude/CLAUDE.md` で継続する。
- **0008** (Git 操作 surface を最小に保つ): Decision の後半 7 項目が Codex の `.rules`（`dot_codex/rules/git-*.rules`）による command guard を前提としており、その rule 体系が存在しない。Claude surface の permission rule は `settings.json` にあり、`git status` / `git add` / `git commit` の allow は built-in と default に委ねていて個別には置いていない。前半の skill 構成に関する判断も本 ADR で一緒に退役する。
- **0011** (Codex skill and reviewer surface を整理する): 整理対象の skill surface と reviewer agent が両方とも存在しない。
- **0015** (RTK を Codex shell proxy として不採用にする): `dot_codex/RTK.md` の削除と `dot_codex/AGENTS.md` からの参照除去が決定内容。Codex surface 自体が無い。
- **0018** (Git mutation rules を既定 prompt に任せる): ADR 0008 を Amend したもので、同じ `dot_codex/rules/git-*.rules` の allow rule 体系を前提に、allow を読み取り操作へ限定する範囲を定めていた。その rule 体系が存在しない。「staging と commit 作成は明示 prompt で扱う」という判断は、`git-commit` skill の停止線と `settings.json` の default 委譲として継続する。
- **0036** (Codex surface を軽量化し両 surface を対称に戻す): 「両 surface を対称にする」という決定を本 ADR が正面から覆す。軽量 LLM-native workflow（進行はガイド、doc は後追い 3 層、agent は read-only 3 つ）は Claude surface 側で継続する。
- **0038** (reviewer subagent に read-only Bash を許可し両 surface の fallback を対称化する): 目的が Codex reviewer との対称化。前提が消えた。reviewer subagent に read-only Bash を許可するかは、`dot_claude/agents/` の再構築時に改めて判断する。

Codex 廃止とは別の経緯で前提を失っていたものも、台帳を実態に合わせるため本 ADR でまとめて退役させる。

- **0013** (PRD と architecture 改善の skill surface を追加する): 追加対象の `architecture` skill と、PRD draft の生成元だった `planning` / `research` skill がいずれも存在しない。`CONTEXT.md` 体系も ADR 0037 で撤去済み。
- **0019** (planning と docs surface を grill / scribe に分割する): 分割先の `grill` skill が存在しない。`scribe` は残るが、本 ADR が与えた PRD / 要件定義 / 設計 / 実装計画 / CONTEXT の責務は既に外れ、後追い doc（README / docs、ADR、notes）に絞られている。「問い詰めと文書化を別の入口に分ける」という責務分離の原則は、doc を書く責務を `scribe` に閉じる形で継続する。

次の ADR は Codex に言及するが、判断は surface に依存しないか既に完了しているため、`Accepted` のまま維持する。

- **0002** (project-specific knowledge は project の `docs/` に置く)
- **0007** (ハーネス検証専用スクリプトを廃止する)
- **0037** (CONTEXT.md 体系を撤去する)
- **0039** (`docs/requests` 配下の既存 artifact を整理して廃止する)
