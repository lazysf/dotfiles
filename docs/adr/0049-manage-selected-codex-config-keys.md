# 0049: Codex の config.toml の一部のキーだけを chezmoi で上書きする

- Status: Accepted
- Amends: 0044

## 背景

ADR 0044 で、`~/.codex/config.toml` を repo から配布しないと決めた。そのため、model、sandbox、アプリの表示の設定は、作業機ごとに手で揃えていた。このファイルには MCP、plugin、marketplace の設定もあり、アプリの導入先など作業機固有のパスが入る。

## 決定

`dot_codex/modify_private_config.toml` の chezmoi の modify テンプレートで、決めたキーだけを上書きする。他のキーは、実機のファイルにあるまま残す。管理するキーと理由は [Codex harness の運用](../notes/codex-harness-operation.md#configtoml-の一部のキーの管理) にある。

permission profile と認証情報の deny は、引き続き作業機の config で管理する。ADR 0044 のきっかけになった、仕事用の Windows 機で Codex の task が起動しなかった配布には、これらが入っていたため。

## 検討した代替案

- **ファイル全体を配布する**: ADR 0043 の形。Codex が書き込んだ MCP や plugin の設定が、apply のたびに消える。
- **Codex の `config/batchWrite` で反映する**: ADR 0046 の形。apply から Codex を呼ぶ script を保守することになる。chezmoi の標準機能で足りる。
- **profile のファイルに分ける**: [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic) では、profile は `--profile` で選んだ時だけ読まれる。アプリでの選び方は docs に無い。
- **管理しないまま続ける**: 作業機の間で値がずれる。

## 影響

管理するキーを Codex のアプリで変えても、次の `chezmoi apply` で repo の値に戻る。値が違う時は、ファイル全体が `toToml` の書式で書き直される。
