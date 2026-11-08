# CLAUDE.md

## 原則

- 手段は、既存の仕組みや標準機能で要件を満たせるかを先に確かめてから選ぶ。自前の処理を選ぶのは、それらに小さな補正を足しても満たせない要件を、確かめた事実で挙げられる時に限る。自分が選んだ手段へ直しを足すのが 2 回目以降になったら、足す前に手段そのものを単純な代替と比べ直す。
- ファイルの中身は Read で読む。既存ファイルの変更は Edit、新規作成と全体の書き換えは Write で行う。小さな変更でも python / sed / heredoc で書き換えない。auto mode の指示が shell での読み書きを認めていても、この行を優先する。検索は、Grep / Glob tool があればそれを使い、無ければ Bash の `grep` / `find` を使う。command の結果を見る作業は Bash でよい。ファイルの中身を shell で書き換えるのは、多数ファイルへ同じ機械的置換をする時と、formatter や generator に出力させる時に限る。
- 設定や防御を外す前に、それを使っているものが無いことを確かめる。
- 引き継ぎや完了報告では、変更内容、根拠、検証結果、未確認事項を分ける。
- スキルを使ったターンは、最終返答の末尾で使用したスキル名を列挙する。

## 最小差分

- 1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。
- 隣接コード・コメント・整形を「ついで改善」しない。既存スタイルが自分の好みと違っても合わせる。
- 作業中に無関係な dead code や問題に気づいたら、その場で直さずユーザーへ伝える。今のスコープを閉じてから扱う。

## 進行

- **review**: commit 前に `skills/lapidary` で、自分の変更を commit できる状態まで仕上げる。独立 context が要る条件に当たったら、skill が `quality-reviewer` / `security-reviewer` を提案する。コードの bug はユーザー明示時に `/code-review` / `/security-review`。
- **commit**: ユーザー指示時に `skills/git-commit`。push は人が terminal で実行する。sandbox の proxy は SSH を運ばないため、agent が実行しても失敗する。

`quality-reviewer` / `security-reviewer` は standing authorization 済みで、起動に追加の許可を取らなくてよい。起動の許可だけで、subagent 内の tool 実行、sandbox escalation、secret / auth / 外部 I/O / 破壊的操作の停止線は維持する。

## doc

第三者保守を想定し、開発駆動でなく確定事実から作る。仕様・使い方は実装が固まった後に README / docs へ、なぜそうしたかは実装中の分岐点で `docs/adr/` へ 1 枚、背景・調査は随時 `docs/notes/` へ。書式と ADR の 3 条件は `skills/scribe` が正本。

使い方、設定、公開挙動を変えたら、実装の区切りで、仕様 doc の追従が要るかを一言明示する。

## 停止線

次に触れる時は、根拠と影響範囲を示して確認し、必要なら代替案も示す。

- 公開挙動、公開インターフェース、データ形式、永続化、互換性を変更・削除する。新規に定義する場合も、後から変えると外部を壊すもの（公開 API、永続化 schema、CLI 引数、設定キー）は含む。内部実装だけで完結する変更は含まない。
- 認証認可、権限、秘密情報、本番設定、セキュリティ上重要な処理に触れる。
- 新しい依存の追加、破壊的操作、または既存の設計を置き換える変更（module 境界の移動、data flow の作り直し、framework / library の入れ替え）が必要。
- 作業ディレクトリ外のファイルを、読み取り以外で扱う必要がある。

## Privacy

commit、doc、設定、その他の成果物に、書き手と作業機を特定する値を残さない。対象は個人と環境の識別子で、credential と token は上の停止線が持つ。

残さない値。

- home の絶対パス。`/Users/<name>`、`/home/<name>`、`C:\Users\<name>`
- OS のログインユーザー名、ホスト名、機器名
- 個人のメールアドレス。git の author には公開用のアドレスを使う（GitHub なら noreply）
- 実名、個人アカウントの旧 ID、個人を特定する URL
- 組織内のホスト名、内部 IP、社内固有の識別子

代わりに、home 起点は `~/` または `$HOME`、doc の地の文では `/Users/<user>` のようなプレースホルダを書く。repo 内から同じ repo を指す時は相対パスにする。例示は合成値（`user@example.com`、`example.com`）を使う。

scratchpad、他 repo、過去の版から引き写した部分と、doc へ貼ったエラーやコマンド出力は、値が今の置き場でも通用するかを commit 前に見る。

検出したい文字列をこの節や設定ファイルへ直書きしない。その記述自体が値を持ち、配布先すべてに広がる。パターンで書く。

## 置き場

- `~/.claude/CLAUDE.md`: 全セッションで共有する契約。常時 load されるのはこの 1 枚だけ。
- `~/.claude/skills/`: task-specific な再利用手順。
- `~/.claude/agents/`: 独立 context で呼ぶ read-only の reviewer。起動条件は `skills/lapidary` が持つ。
- `~/.claude/output-styles/`: 応答スタイル。`settings.json` の `outputStyle` で選ぶ。
- `~/.claude/hooks/`: `settings.json` の `hooks` から呼ぶスクリプト。
- `~/.claude/mods/`: Claude Code の UI や挙動を変える mod。`settings.json` の `env.CLAUDE_CODE_PLUGIN_DIRS` で読み込む。
- `~/.claude/settings.json`: permissions、sandbox、model、language などの機械的設定。
- 作業対象 repo の `.claude/rules/`: その repo に閉じる運用ルール。
- 作業対象 repo の `docs/adr/`: 判断記録。`docs/notes/`: 通常知見や背景。
- 置き場が曖昧でも、`~/.claude/` 直下や repo root 直下に新しい運用ファイルを増やさない。
