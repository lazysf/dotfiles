# mise tool matrix

このメモは、mise で導入する repo-local な runtime / formatter / linter と、nvim の扱いをまとめる。

正本:

- [`mise.toml`](../../mise.toml): この repo の保守に使う runtime / formatter / linter
- [`dot_config/mise/config.toml.tmpl`](../../dot_config/mise/config.toml.tmpl): global に tool を置かない方針
- [`dot_config/nvim/lua/core/encoding_map.lua`](../../dot_config/nvim/lua/core/encoding_map.lua): nvim のファイル別 encoding / fileformat 設定

VSCode を主 IDE とし、nvim はテキスト編集用に寄せる。formatter / linter は `mise` task から実行し、nvim には formatter / linter / LSP / DAP / 補完エンジンを割り当てない。
Windows の PowerShell は Scoop 管理の `pwsh.exe` を既定とし、mise の `powershell` runtime 管理からは外す。
Node と Python / uv は root `mise.toml` で指定し、global の mise config には置かない。
Rust は mise global 管理から外し、必要になった場合だけ rustup 側の toolchain として導入する。
その他の言語 runtime / formatter / linter も、必要な project の `mise.toml` に置く。

| 対象         | runtime / toolchain | formatter      | linter              | nvim での扱い       | 備考                                          |
| ------------ | ------------------- | -------------- | ------------------- | ------------------- | --------------------------------------------- |
| Node CLI     | `node`              | なし           | なし                | テキスト編集のみ    | `npm:*` tool の実行基盤として repo local 管理 |
| Python       | `python`, `uv`      | 未設定         | 未設定              | テキスト編集のみ    | repo 保守用 Python 環境として repo local 管理 |
| PowerShell   | OS 別               | 未設定         | 未設定              | BOM 付き UTF-8 / LF | mise では管理しない                           |
| Shell        | なし                | `shfmt`        | なし                | テキスト編集のみ    | shell lint は未設定                           |
| Zsh          | なし                | `shfmt`        | なし                | テキスト編集のみ    | nvim からは syntax check しない               |
| TOML         | なし                | `tombi`        | `tombi`             | テキスト編集のみ    | format / lint は CLI を使う                   |
| Markdown     | なし                | `npm:prettier` | `markdownlint-cli2` | テキスト編集のみ    | repo task で format / lint する               |
| YAML         | なし                | `npm:prettier` | `pipx:yamllint`     | テキスト編集のみ    | repo task で format / lint する               |
| JSON / JSONC | なし                | `npm:prettier` | 未設定              | テキスト編集のみ    | 現在の task は `.markdownlint.jsonc` 対象     |
| Lua          | なし                | `cargo:stylua` | `cargo:selene`      | テキスト編集のみ    | Cargo 経由で導入する Lua 用ツール             |

Go、Rust、SQL、Dockerfile、JavaScript / TypeScript 固有の formatter / linter は、この repo の
root `mise.toml` には置かない。必要な project の `mise.toml` で指定する。

`npm:*`、`pipx:*`、`cargo:*` の prefix は導入元を示すだけで、対象言語そのものを示すとは限らない。
nvim 側の filetype 判定や Tree-sitter は構文表示のために残すが、外部 CLI とは接続しない。
