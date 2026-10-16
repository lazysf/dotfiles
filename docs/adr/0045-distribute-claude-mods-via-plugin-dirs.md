# 0045: Claude Code の mod を CLAUDE_CODE_PLUGIN_DIRS で配布する

- Status: Accepted

## 背景

Claude Code の mod（hooks module で UI や挙動を変える plugin）として、プロンプトの上に 5 時間と週の使用率バーを出す `usage-band` を作った。session の中で作った mod は session 固有の `~/.claude/dev-mods/<session-id>/` に置かれ、他の session や作業機には届かない。

## 決定

mod の source を `dot_claude/mods/<name>/` に置き、chezmoi で `~/.claude/mods/<name>/` へ配る。`dot_claude/settings.json` の `env.CLAUDE_CODE_PLUGIN_DIRS` で配った folder を指し、作業機で起動する session で読み込む。

公式の [Mods reference](https://code.claude.com/docs/en/plugins/mods/reference#settings-and-environment-variables) は、この変数を process 環境か `~/.claude/settings.json` の `env` から読むと書いている。`--plugin-dir` を渡せない desktop app でも効く手段として挙げられている。[Environment variables](https://code.claude.com/docs/en/env-vars) によると、各 path は絶対 path か `~` 始まりで書く。v2.1.280 以上が必要になる。

## 検討した代替案

- **folder を marketplace として登録する**: `extraKnownMarketplaces` で folder を marketplace として登録し、`enabledPlugins` で有効にする。marketplace.json と install の手順が要る。mod 1 つを配るには手順が多いので、採らなかった。mod が増えて個別に有効・無効を切り替えたくなったら、再検討の価値がある。
- **dev-mods の folder を使い続ける**: session ごとに folder が変わるので、配布先として固定できない。

## 影響

mod の API は EARLY ACCESS で、release 間で予告なく変わりうる。mod が壊れた時は、`env.CLAUDE_CODE_PLUGIN_DIRS` を外せば読み込みが止まる。

`CLAUDE_CODE_PLUGIN_DIRS` は `--plugin-dir` と同じ読み込み方をするので、interactive session では mod の folder が監視され、保存すると読み直される。

mod の test（`*.test.ts`）は mod と一緒に配布する。engine は test を読み込まず、展開先で `claude plugin test` を走らせられる。interactive session が監視する folder には、engine が型定義と `tsconfig.json` を書く。それらは target だけにでき、chezmoi の管理外になる。

Codex には mod に当たる仕組みが無いので、`dot_codex/` には対応する設定を置かない。
