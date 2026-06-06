# 0037: CONTEXT.md 体系を撤去する

- Status: Accepted
- Amends: 0011

## 背景

この repo は ADR 0009（後継 ADR 0011 で継承）で `CONTEXT-MAP.md` と近傍 `CONTEXT.md` を採用し、context 近傍に glossary を置く形を取った。実体は:

- `CONTEXT-MAP.md`（root）: multi-context の入口
- `docs/CONTEXT.md`: Knowledge Ledger context — Note / ADR / Decision Status / Context / Grilling / Scribing の glossary
- `dot_codex/CONTEXT.md`: Codex ハーネス context — Runtime Surface / Skill / Specialist Agent / Rule の glossary

運用してみて、次が確認された:

- **冗長**: `dot_codex/CONTEXT.md` の用語は `dot_codex/AGENTS.md` 置き場セクションと、`docs/CONTEXT.md` の用語は `skills/scribe/references/adr-format.md` などで重複定義されており、CONTEXT.md 側は二次情報になっている。
- **腐敗**: Grilling / Scribing 等 ADR 0036 で廃止または改修した概念が glossary に残り、古い前提を保持してしまう。
- **届かない**: `.chezmoiignore` で配布対象外のため Codex / Claude agent には届かず、glossary としての発火経路がない。
- **規模に過剰**: 個人 dotfiles 2 surface に bounded context の Context Map 構造は overhead が利得を上回る。
- **軽量化原則と緊張**: ADR 0036 の「事前 doc で駆動しない」「確定事実から」と CONTEXT.md（事前用語定義）は緊張関係。

## 決定

CONTEXT.md 体系を全撤去する。

- `CONTEXT-MAP.md` / `docs/CONTEXT.md` / `dot_codex/CONTEXT.md` の 3 ファイルを削除する。
- 用語の正本は次の通り分散させる:
  - Codex surface の Skill / Specialist Agent / Rule / 置き場: `dot_codex/AGENTS.md`
  - Claude surface 側同等物: `dot_claude/CLAUDE.md`
  - ADR / Decision Status / Status lifecycle: `dot_codex/skills/scribe/references/adr-format.md` と `dot_claude/skills/scribe/references/adr-format.md`
  - notes / 仕様 doc の用語: 各 surface の scribe references
- 参照元（`docs/README.md` / `README.md` / `docs/notes/adr-ledger-model.md` / `.chezmoiignore`）から CONTEXT 関連の記述を取り除く。

## 検討した代替案

- **`dot_codex/CONTEXT.md` だけ削除（部分撤去）**: `docs/CONTEXT.md` と `CONTEXT-MAP.md` を残しても、現役参照元は index 列挙のみで実質情報源として使われていない。半端なので却下。
- **CONTEXT.md を軽量化して残す**: 既に AGENTS.md / scribe references で全用語をカバーしており、軽量化しても冗長性は解消しない。却下。
- **現状維持**: 軽量化思想と緊張、glossary 腐敗の継続。却下。

## 影響

- **ADR 0011 の CONTEXT 部分を Amend**: ADR 0009 から継承された CONTEXT-MAP / 近傍 CONTEXT.md 方針は本 ADR で撤去される。ADR 0011 本文の他部分（skill prune 等）は本 ADR の対象外で、`Amends` 関係に留める。
- **glossary 一元正本の消失**: 用語は AGENTS.md / scribe references に分散するが、それぞれ現役で読まれる経路にあり、実質的な可読性は上がる。
- **`.chezmoiignore` 整理**: `.codex/CONTEXT.md` と `CONTEXT-MAP.md` のエントリが対象ファイル削除で不要になる。
- **共有 note の CONTEXT 言及**: `docs/notes/harness-*` と `runtime-surface-guidance.md` には scope banner（ADR 0036）で「履歴」と明示済みで、CONTEXT 言及はその範囲。本文修正は不要。
