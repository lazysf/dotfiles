# Detailed Design

## 対象範囲

- `dot_claude/skills/orchestrate/SKILL.md` と `dot_codex/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/references/full.md` / `standard.md` / `micro.md` / `gate-review.md` と Codex 側対称ファイル

## Interface 詳細

prose 手順の追加・置換。新しい用語として「前工程確認 (entry check)」と「確認痕跡 (entry note)」を導入する。

- 前工程確認: 次工程着手前に、直前工程の成果物を実際に Read で開き、必要項目が確定しているか確かめる行為。
- 確認痕跡: 「確認した artifact 名 + 満たした観点（1 行）」。`request.md` または `implementation.md` の自然な節に残す。request folder が無い micro では最終出力に含める。

## 詳細設計項目

### DD-001: full.md の Phase 3 entry condition 具体化 (BD-001, BD-002, BD-003 / AC-001, AC-002)

現行 L95-101 の `Phase 3 entry condition` を次の趣旨に書き換える:

- 進め方を「Gate 2 pass 後、Phase 3 着手前に、次の上流 artifact を実際に Read で開いて確認する」とし、対象を列挙: `requirements.md`(REQ/AC が確定)、`basic-design.md`(責務・境界)、`detailed-design.md`(処理・I/O・validation・error handling)、`tasks.md`(作業単位・完了条件・確認方法)。
- 「これらが実装判断に足ることを確認し、確認した artifact 名と充足観点を `implementation.md` または `request.md` の冒頭に1行残してからコードに着手する」。
- 「確認の目的は、記憶や会話の流れでなく成果物そのものを実装の根拠にすること。Read で確認できない、または項目が未確定なら、着手せず Gate 2 以前へ戻すかユーザー確認する。実装結果から後付けで上流 artifact を作らない」。
- skip 不能化: 「痕跡を残していない実装着手は entry condition 未達として扱う」を明記。

### DD-002: standard.md の Phase 3 entry condition 具体化 (BD-001, BD-002, BD-003 / AC-001, AC-002, AC-004)

現行 L67-73 を次の趣旨に書き換える:

- 「Phase 3 着手前に、作成済みの上流 artifact（`requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` のうち作ったもの）を実際に Read で確認する。これらを省略した場合は `request.md` の scope / acceptance / 実装範囲 / 省略理由を Read で確認する」。
- 「確認した artifact 名（または request.md の該当節）と充足観点を `implementation.md` または `request.md` に1行残してから着手する」。
- 「未確定・不足なら後付けで作らず Phase 1/2 へ戻すかユーザー確認する。痕跡なき着手は entry condition 未達」。
- 既存の「実装結果を根拠に上流 artifact を作り直さない」「implementation.md / test.md を上流 artifact の代替にしない」は維持（standard.md L81, L127）。

### DD-003: micro.md に最小 entry 確認を追加 (BD-004 / AC-003, AC-004)

Phase 0 と Phase 3 実装の間に「実装着手前確認」小セクションを追加する:

- 扱い: 必須 / agent: lead / artifact: なし（または request folder がある場合 request.md の節）
- 進め方:「実装着手前に、変更対象ファイルの現状と、何をなぜ変えるか（request 相当の意図）を Read で確認する。request folder を作らない場合は確認内容を最終出力にも反映する。確認の結果、複数 file・設計判断・影響調査が要ると分かったら `standard` 以上へ移す」。
- docs は作らせない。1 ステップの確認に留め micro を重くしない。
- 既存「実装結果を根拠に〜」相当が micro に無いため、実装節 (L21) に「implementation.md / test.md は記録用で、着手判断の根拠は事前確認に置く」趣旨を1行添える (AC-004)。

### DD-004: SKILL.md 本体に原則を1か所追記 (BD-005 / AC-007)

`自走と確認 checkpoint` セクションに次の1項目を追加する（tier 別具体手順は書かない）:

- 「各工程は、直前工程の成果物を実際に Read で確認し、必要項目が確定していることを確かめてから着手する。確認した artifact と充足観点は痕跡として残す。確認できない、または未確定なら着手せず前工程へ戻すかユーザー確認する。これは記憶や会話の流れでなく成果物を根拠に進め、実装先行・docs 後を防ぐため。具体手順は tier reference を見る」。

### DD-005: gate-review.md の pass 条件補強 (BD-006 / AC-002)

共通 pass 条件 L10 を補強する:

- 現行「次工程へ進むために必要な上流 artifact が、次工程着手前に作成・更新・確認されている」に続けて、「lead が前工程成果物を Read 確認した痕跡（確認 artifact 名と充足観点）が残っている」を加える。
- 共通 fail 条件側にも整合する1項目を加えるか検討するが、現行 fail L20「実装や検証の結果を根拠に上流 artifact を後付けしている」で後付けは既にカバーされるため、痕跡欠如は pass 条件の不充足として扱い fail 条件の新規追加は最小限に留める。

### DD-006: 両 surface 対称反映 (BD-007 / AC-005)

DD-001〜DD-005 を `dot_codex/skills/orchestrate/` 側に surface 名（Claude→Codex, subagent→agent）以外同内容で反映する。

## 処理フロー

1. SKILL.md（Claude）に DD-004 を追記。
2. full.md（Claude）に DD-001 を反映。
3. standard.md（Claude）に DD-002 を反映。
4. micro.md（Claude）に DD-003 を反映。
5. gate-review.md（Claude）に DD-005 を反映。
6. 1〜5 を Codex 側に対称反映（DD-006）。
7. 両 surface の対応ファイル diff を確認し surface 名以外一致を検証。

## Validation

- 各遷移点に「Read で確認」「痕跡を残す」「未充足なら前工程へ戻す/ユーザー確認」の3要素が揃っているか。
- Tier Map・docs 省略規定が無変更か (AC-006)。
- SKILL.md 追記が tier 具体手順の重複転記でないか (AC-007)。

## Error Handling

- N/A（prose 変更。実行時 error handling は対象外）。

## Edge Case

- micro で request folder を作らないケース: 痕跡は最終出力に含める（DD-003）。
- standard で上流 artifact を全省略したケース: request.md の該当節を確認対象・痕跡対象にする（DD-002）。

## 状態遷移 / 分岐条件

- 各遷移点の分岐: 前工程成果物が Read 確認で充足 → 着手 / 不足・未確定 → 前工程へ戻す or ユーザー確認。

## Test 観点

- full.md / standard.md / micro.md / gate-review.md / SKILL.md（両 surface）に AC-001〜AC-007 対応の記述が入ったか grep で確認。
- `diff` で Claude/Codex 対応ファイルが surface 名以外一致するか。
- Tier Map と docs 省略規定が無変更か（diff 範囲確認）。
- 既存 reference 内リンク・参照が壊れていないか。

## 未確認事項

- none（micro は1ステップ確認に確定）。
