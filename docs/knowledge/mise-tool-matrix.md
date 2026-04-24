# mise tool matrix

このメモは、mise で導入する runtime / formatter / linter と、nvim の扱いをまとめる。

正本:

- [`dot_config/mise/config.toml.tmpl`](../../dot_config/mise/config.toml.tmpl): mise で導入する CLI
- [`dot_config/nvim/lua/core/encoding_map.lua`](../../dot_config/nvim/lua/core/encoding_map.lua): nvim のファイル別 encoding / fileformat 設定

VSCode を主 IDE とし、nvim はテキスト編集用に寄せる。formatter / linter は `mise` task から実行し、nvim には formatter / linter / LSP / DAP / 補完エンジンを割り当てない。

| 対象 | runtime / toolchain | formatter | linter | nvim での扱い | 備考 |
| --- | --- | --- | --- | --- | --- |
| Go | `go` | `gofmt` | `golangci-lint` | テキスト編集のみ | `gofmt` と `go vet` は Go toolchain 側の標準ツールとして扱う |
| JavaScript / TypeScript | `node` | `biome` | `biome` | テキスト編集のみ | JSX / TSX も同じ CLI を使う |
| JSON / JSONC | `node` | `npm:prettier` | `biome` | テキスト編集のみ | formatter と linter で別 CLI を使う |
| Python | `python` | `ruff` | `ruff` | テキスト編集のみ | Python 補助 tooling として `uv` も導入する |
| PowerShell | `powershell` | 未設定 | 未設定 | UTF-8 / LF | `*.ps1` は BOM なし UTF-8 と LF で扱う |
| Rust | `rust` | `rustfmt` | `clippy` | テキスト編集のみ | `rustfmt` と `clippy` は Rust toolchain 側の標準コンポーネントとして扱う |
| Shell | なし | `shfmt` | `shellcheck` | テキスト編集のみ | nvim からは lint しない |
| Zsh | なし | `shfmt` | なし | テキスト編集のみ | nvim からは syntax check しない |
| TOML | なし | `taplo` | `taplo` | テキスト編集のみ | format / lint は CLI を使う |
| Markdown | なし | `npm:prettier` | `markdownlint-cli2` | テキスト編集のみ | repo task で prettier / markdownlint-cli2 を使う |
| YAML | なし | `npm:prettier` | `pipx:yamllint` | テキスト編集のみ | repo task で prettier / yamllint を使う |
| SQL | なし | `pipx:sqlfluff` | `pipx:sqlfluff` | テキスト編集のみ | formatter と linter を同じ CLI で担う |
| Lua | なし | `cargo:stylua` | `cargo:selene` | テキスト編集のみ | Cargo 経由で導入する Lua 用ツール |
| Dockerfile | なし | `dprint` | `hadolint` | テキスト編集のみ | nvim からは format / lint しない |

`npm:*`、`pipx:*`、`cargo:*` の prefix は導入元を示すだけで、対象言語そのものを示すとは限らない。
nvim 側の filetype 判定や Tree-sitter は構文表示のために残すが、外部 CLI とは接続しない。
