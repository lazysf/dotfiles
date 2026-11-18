# SECURITY / SUPPORT 形式

`SECURITY.md` と `SUPPORT.md` を作成・更新する時に読む。作る条件（窓口を開く repo）と GitHub が認識する置き場は、`../SKILL.md` の「置き場の選び方」を正本にする。

## 共通

- 窓口（アドレス、フォーム、GitHub の private vulnerability reporting、議論の場）は推測で書かない。repo から読めなければユーザーに聞く。実在しない窓口を書くと、報告が届かない。
- 窓口が決まらない間は、ファイルを作らない。空の雛形は、窓口があるように見せる。

## `SECURITY.md`

### 構成

当てはまる節を、次の順で書く。1 と 2 は [GitHub の security policy](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository) が挙げる項目。

1. 対応する版: 修正を出す版の範囲。
2. 報告の方法: 窓口と、報告に含めてほしい情報（再現の手順、影響、版）。
3. 報告の後の流れ: 受け取った後に何をするか。

### 書く規則

- 脆弱性を公開の issue や PR に書かないよう案内する。
- 対応する版の範囲と報告の後の流れは、実際にそうしている事実だけを書く。約束できない期限を書かない。
- GitHub の private vulnerability reporting は repo の設定で、有効かは repo から読めない。窓口にする時は、有効にしたかをユーザーに確かめ、`SECURITY.md` からその窓口を案内する。

## `SUPPORT.md`

### 構成

当てはまる節を、次の順で書く。

1. 質問の場: 使い方の質問をどこでするか。
2. bug の報告先: issue のテンプレートがあれば、そこへ指すだけにする。
3. 返答の目安: 実際にそうしている時だけ書く。

### 書く規則

- README の「助けと貢献」から `SUPPORT.md` を指す。
- 質問が bug の issue に混ざる時は、issue のテンプレートの `config.yml` で質問の場へ誘導する。書き方は `development-format.md` の「issue と PR のテンプレート」に従う。
