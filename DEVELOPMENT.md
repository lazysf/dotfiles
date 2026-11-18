# DEVELOPMENT

この repo の source を直す時の手順。

## 前提と環境構築

commit 時の hook を入れる。hook は lint、作業機の識別子（home の絶対パス、ユーザー名、ホスト名）の検査、commit message の title が `<type>: <description>` の形かの検査を走らせる。commit-msg の hook を足す前に入れた clone でも、もう一度打つ:

```sh
prek install
```

手で lint する時の道具（`rumdl`、`tombi`）を入れる:

```sh
npm install
```

repo の保守用 Python を用意する。版は `pyproject.toml` の `requires-python` に従う:

```sh
uv sync
```

## 変更の確かめ方

Markdown を変えたら lint する。`npm run lint:fix` で直せるものは直す:

```sh
npm run lint
```

TOML を変えたら lint する。`npm run lint:toml:fix` で整形も直す:

```sh
npm run lint:toml
```

commit 時にも、prek の hook が同じ設定で走る。2 つの経路の違いは [`docs/notes/lint-and-pre-commit-execution.md`](docs/notes/lint-and-pre-commit-execution.md) にある。
