# DEVELOPMENT / CONTRIBUTING 形式

`DEVELOPMENT.md`、`CONTRIBUTING.md`、issue と PR のテンプレートを作成・更新する時に読む。読み手が違う。`DEVELOPMENT.md` は開発に加わる人が手順を引く doc、`CONTRIBUTING.md` は外部の貢献者が出し方を確かめる doc、テンプレートは外部の貢献者が issue や PR を書く時の下書き。

## 共通

- 既定の置き場は repo root。同じ目的の doc（`HACKING.md` など）が repo にあれば、そちらに書く。`CONTRIBUTING.md` の置き場は `../SKILL.md` の「置き場の選び方」に従う。
- 片方しか無い repo で、もう片方の中身も書いてある時は、無理に分けない。新しく足す内容から、2 つのどちらかへ置く。
- 利用者向けの使い方、判断の理由、調査の経緯は書かない。置き場は `../SKILL.md` の「置き場の選び方」の表に従う。
- 道具の一般的な使い方は書かない。判定は README と同じで、「この文は、同じ道具を使うどの project でも同じか」。

## `DEVELOPMENT.md`

読み手は、開発に加わる人。agent は `AGENTS.md` から指されれば同じものを読むので、agent 向けに書き分けない。

### 構成

当てはまるものを、次の順で書く。当てはまらない節は作らない。

1. 前提と環境構築: 必要な tool と版、依存の入れ方。
2. 内部の構成: repo に `ARCHITECTURE.md` があれば、そちらに書く。
3. 変更の確かめ方: lint、試験、build のコマンドと、いつ走らせるか。
4. branch と commit: branch の切り方、commit や PR の決まり。
5. リリース: 版の上げ方、tag、配布。

### 書く規則

- コマンドは、repo の定義（`package.json` の scripts、Makefile、CI の設定）と合わせる。
- 内部の構成は、[ARCHITECTURE.md](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html) の順で書く。
  1. 全体像: この system が何を解くか。
  2. コードの地図: どこに何があるか。どの directory と module が何をするか。
  3. 変えてはいけない前提: 「〜は〜に依存しない」のような、何かが無いことの前提も書く。
  4. 層の境界: module や system の境目と、境目を越える時の決まり。
  5. 横断する関心事: 設定、ログ、エラーの扱いなど、複数の module にまたがるもの。
- 内部の構成には、ファイルや module の名前を挙げるが、リンクは張らない。リンクは rename ですぐ切れ、名前は検索で辿れる。
- 内部の構成には、すぐ変わる細部（関数の一覧、行番号）を書かない。

## `CONTRIBUTING.md`

外部からの貢献を受け付ける repo の時だけ作る。受け付けるかが repo から読めない時は、ユーザーに聞く。GitHub はこのファイルを issue や PR を作る画面からリンクするので、受け付けない repo に置くと、受け付けているように見える。

### 構成

当てはまるものを、次の順で書く。中身の範囲は [GitHub の contributor guidelines](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors) と [Open Source Guide](https://opensource.guide/starting-a-project/) に沿う。

1. 歓迎する貢献: どんな貢献を受け付けるか。
2. 質問と連絡の先: `SUPPORT.md` があれば指す。
3. bug の報告: issue のテンプレートがあれば指す。
4. 機能の提案: 提案の出し方と、受け付けるかの決め方。
5. PR の出し方: branch の規則と確かめ方のコマンドは書かず、`DEVELOPMENT.md` の該当する節へリンクする。
6. 受け付けない変更: その理由と一緒に書く。
7. 行動の規範: `CODE_OF_CONDUCT.md` があれば指す。

### 書く規則

- README の「助けと貢献」から `CONTRIBUTING.md` を指す。

## issue と PR のテンプレート

`CONTRIBUTING.md` を作る repo の時だけ作る。

### 置き場と命名

- issue は `.github/ISSUE_TEMPLATE/` に種類ごとのファイルを置く。PR は `.github/PULL_REQUEST_TEMPLATE.md` に置く。
- テンプレートは default branch に無いと効かない。

### 構成

- 既存のテンプレートの形式に従う。無ければ Markdown のテンプレート（`.md`）にする。YAML の issue form は、GitHub が public preview としている（[Configuring issue templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)）。
- Markdown のテンプレートは、front matter に `name` と `about` を持たせる。issue form は `name`、`description`、`body` を持たせる。
- 本文には、記入してほしい項目（再現の手順、期待した動作、確かめたこと）を並べる。
- `.github/ISSUE_TEMPLATE/config.yml` では、`contact_links` で質問を `SUPPORT.md` や Discussions へ、脆弱性を `SECURITY.md` の窓口へ誘導する。テンプレートを必ず使わせる時は、`blank_issues_enabled: false` にする。

```yaml
blank_issues_enabled: false
contact_links:
  - name: [質問の場の名前]
    url: [実在する URL]
    about: [何をここで聞くか。]
```

### 書く規則

- 受け付ける方針、受け付けない変更、その理由は `CONTRIBUTING.md` に置き、テンプレートには写さない。
- `contact_links` の先は、実在するものだけを書く。窓口を推測しない規則は `community-files-format.md` と同じ。

## `AGENTS.md` との分担

agent は `AGENTS.md`（Claude Code では `CLAUDE.md`）を自動で読むが、`DEVELOPMENT.md` は読まない。人と agent の両方に効く手順は `DEVELOPMENT.md` を正本にする。`AGENTS.md` にコマンドを写すと、片方だけ古くなる。

`AGENTS.md` からは、読む時期を付けて指してもらう。時期を書くと、コマンドを走らせる場面で読む手がかりになる。`AGENTS.md` はこの skill では直さないので、次のような 1 行を提案する。

```markdown
lint や試験を走らせる前に、`DEVELOPMENT.md` の「変更の確かめ方」を読む。
```
