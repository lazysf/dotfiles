# mise tool matrix

このメモは、mise で導入する runtime / formatter / linter と、nvim の filetype 割り当ての対応をまとめる。

正本:

- [`dot_config/mise/config.toml.tmpl`](../../dot_config/mise/config.toml.tmpl): mise で導入する CLI
- [`dot_config/nvim/lua/plugins/conform.lua`](../../dot_config/nvim/lua/plugins/conform.lua): nvim formatter 割り当て
- [`dot_config/nvim/lua/plugins/nvim-lint.lua`](../../dot_config/nvim/lua/plugins/nvim-lint.lua): nvim linter 割り当て

| 対象 | runtime / toolchain | formatter | linter | nvim filetype | 備考 |
| --- | --- | --- | --- | --- | --- |
| Go | `go` | `gofmt` | `golangci-lint` | `go` | `gofmt` と `go vet` は Go toolchain 側の標準ツールとして扱う |
| JavaScript / TypeScript | `node` | `biome` | `biome` | `javascript`, `javascriptreact`, `typescript`, `typescriptreact` | JSX / TSX も同じ割り当て |
| JSON / JSONC | `node` | `npm:prettier` | `biome` | `json`, `jsonc` | formatter と linter で別 CLI を使う |
| Python | `python` | `ruff` | `ruff` | `python` | Python 補助 tooling として `uv` も導入する |
| PowerShell | `powershell` | 未設定 | 未設定 | 未設定 | `PSScriptAnalyzer` は未導入の外部候補で、本体内蔵ではない |
| Rust | `rust` | `rustfmt` | `clippy` | `rust` | `rustfmt` と `clippy` は Rust toolchain 側の標準コンポーネントとして扱う |
| Shell | なし | `shfmt` | `shellcheck` | `bash`, `sh` | nvim では bash / sh に `shellcheck` を使う |
| Zsh | なし | `shfmt` | `zsh -n` | `zsh` | nvim では `shellcheck` ではなく zsh の syntax check を使う |
| TOML | なし | `taplo` | `taplo` | `toml` | Taplo LSP は LSP のみに使い、format / lint は CLI を使う |
| Markdown | なし | `npm:prettier` | `markdownlint-cli2` | `markdown` | repo task でも prettier / markdownlint-cli2 を使う |
| YAML | なし | `npm:prettier` | `pipx:yamllint` | `yaml`, `yml` | repo task でも prettier / yamllint を使う |
| SQL | なし | `pipx:sqlfluff` | `pipx:sqlfluff` | `sql` | formatter と linter を同じ CLI で担う |
| Lua | なし | `cargo:stylua` | `cargo:selene` | `lua` | Cargo 経由で導入する Lua 用ツール |
| Dockerfile | なし | `dprint` | `hadolint` | `dockerfile` | 現状 nvim では Dockerfile formatter として `dprint` を使う |

`npm:*`、`pipx:*`、`cargo:*` の prefix は導入元を示すだけで、対象言語そのものを示すとは限らない。
nvim 側の adapter / linter ID は CLI 名と表記が異なる場合があるが、別ツールとしては扱わない。
