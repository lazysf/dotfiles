# DEVELOPMENT / CONTRIBUTING 形式

`DEVELOPMENT.md`、`CONTRIBUTING.md`、issue と PR のテンプレートを作成・更新する時に読む。読み手が違う。`DEVELOPMENT.md` は開発に加わる人が手順を引く doc、`CONTRIBUTING.md` は外部の貢献者が出し方を確かめる doc、テンプレートは外部の貢献者が issue や PR を書く時の下書き。

## 共通

- 既定の置き場は repo root。同じ目的の doc（`HACKING.md` など）が repo にあれば、そちらに書く。
- 片方しか無い repo で、もう片方の中身も書いてある時は、無理に分けない。新しく足す内容から、2 つのどちらかへ置く。
- 利用者向けの使い方、判断の理由、調査の経緯は書かない。置き場は `../SKILL.md` の「置き場の選び方」の表に従う。
- 道具の一般的な使い方は書かない。判定は README と同じで、「この文は、同じ道具を使うどの project でも同じか」。

## `DEVELOPMENT.md`

読み手は、開発に加わる人。agent は `AGENTS.md` から指されれば同じものを読むので、agent 向けに書き分けない。

当てはまるものを、次の順で書く。当てはまらない節は作らない。

1. 前提と環境構築: 必要な tool と版、依存の入れ方。
2. 内部の構成: module の責務と境界、変えてはいけない前提、どこに何の処理があるか。repo に `ARCHITECTURE.md` があれば、そちらに書く。
3. 変更の確かめ方: lint、試験、build のコマンドと、いつ走らせるか。
4. branch と commit: branch の切り方、commit や PR の決まり。
5. リリース: 版の上げ方、tag、配布。

- コマンドは、repo の定義（`package.json` の scripts、Makefile、CI の設定）と合わせる。
- 確かめ方のコマンドは、書いた形のまま一度走らせる。リリースや配布のように外へ出るコマンドは走らせず、定義と突き合わせるだけにする。
- 内部の構成には、すぐ変わる細部（関数の一覧、行番号）を書かない。

## `CONTRIBUTING.md`

外部からの貢献を受け付ける repo の時だけ作る。受け付けるかが repo から読めない時は、ユーザーに聞く。GitHub はこのファイルを issue や PR を作る画面からリンクするので、受け付けない repo に置くと、受け付けているように見える。

- 書くもの: issue と PR の出し方、受け付けない変更、行動の規範への指し先。
- PR の出し方の中でも、branch の規則と確かめ方のコマンドは書かず、`DEVELOPMENT.md` の該当する節へリンクする。
- GitHub は root、`docs/`、`.github/` のどこに置いても認識する。複数あると `.github/`、root、`docs/` の順で 1 つだけを使うので、2 つ置かない。

## issue と PR のテンプレート

`CONTRIBUTING.md` を作る repo の時だけ作る。issue は `.github/ISSUE_TEMPLATE/` に種類ごとのファイル、PR は `.github/PULL_REQUEST_TEMPLATE.md` に置く。

- 書くもの: 記入してほしい項目（再現の手順、期待した動作、確かめたこと）。
- 受け付ける方針、受け付けない変更、その理由は `CONTRIBUTING.md` に置き、テンプレートには写さない。

## `AGENTS.md` との分担

agent は `AGENTS.md`（Claude Code では `CLAUDE.md`）を自動で読むが、`DEVELOPMENT.md` は読まない。人と agent の両方に効く手順は `DEVELOPMENT.md` を正本にする。`AGENTS.md` にコマンドを写すと、片方だけ古くなる。

`AGENTS.md` からは、読む時期を付けて指してもらう。時期を書くと、コマンドを走らせる場面で読む手がかりになる。`AGENTS.md` はこの skill では直さないので、次のような 1 行を提案する。

```markdown
lint や試験を走らせる前に、`DEVELOPMENT.md` の「変更の確かめ方」を読む。
```
