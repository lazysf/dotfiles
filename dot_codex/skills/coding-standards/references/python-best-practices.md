# Python Best Practices

`ruff` で format / lint する前提で、整形だけでは決まらない Python の判断を補う資料。

## 目次

- 命名規則
- エラー処理の目安
- データと構造の目安
- 関数引数と返り値
- ワンライナーと制御フロー
- 内包表記と generator
- 構文の選び方
- import と API 境界
- 避けたいこと

## 命名規則

- 関数、変数、モジュールは `snake_case`、クラスは `PascalCase`、定数は `UPPER_SNAKE_CASE` を基本にする。
- 型そのものより、役割や責務が読める名前を優先する。
- Bool は述語名を基本にし、`flag` や `status` のような曖昧名や、読みづらい否定形を増やしすぎない。

```python
# avoid
def process(data):
    ...
class UserManager:
    ...
flag = user is not None
user_records = fetch_user_records()
primary_record = user_records[0]

# prefer
def build_user_summary(user):
    ...
class UserSummary:
    ...
is_user_loaded = user is not None
```

## エラー処理の目安

- 回復できない失敗を広すぎる `except` で握りつぶさない。
- 例外を補足するのは、CLI、HTTP、ファイル I/O などの境界で利用者向けの文脈を足す場合に寄せる。
- `None` を返すのか例外を送出するのかは、近傍実装の契約に合わせて混在させない。
- 例外を包み直すときは、元の失敗原因が追える形を崩さない。

## データと構造の目安

- 一時的な入出力の受け渡しは、必要以上にクラス化せず `dict` や既存の型に寄せる。
- 値オブジェクトとして意味が固定される場合だけ `dataclass` を検討する。
- ミュータブルなデフォルト引数は避け、必要なら `None` から初期化する。
- 関数は入力変換、計算、永続化や外部呼び出しを必要以上に混ぜない。

## 関数引数と返り値

- 引数が増えすぎる場合は、真っ先にフラグを足すのではなく責務分割や入力構造の見直しを考える。
- 引数名も返り値も、呼び出し側が意味を追える形を優先する。
- `None` を特別値として使う場合は、役割を混在させない。

```python
# avoid
def export_user(user, flag, data=None):
    ...

# prefer
def export_user(user, should_notify, export_options=None):
    ...

user_summary = load_user_summary(user_id)
```

## ワンライナーと制御フロー

- 複文ワンライナーは避け、早期 `return` / `continue` でネストを浅く保つ。
- 三項演算子は短く単純な場合だけに留め、条件が重いなら通常の分岐へ戻す。
- 複雑な条件は、意味のある途中変数や述語関数へ分ける。

```python
# avoid
if is_ready: start_job()

# prefer
if not is_ready:
    return
start_job()

# avoid
state_label = "ready" if job and job.is_ready and job.owner else "pending"

# prefer
can_start_job = job is not None and job.is_ready and job.owner is not None
state_label = "ready" if can_start_job else "pending"
```

## 内包表記と generator

- 単純な変換やフィルタは内包表記でよい。
- 複雑な条件、深いネスト、副作用がある場合は `for` 文へ戻す。
- `any` / `all` / `sum` に渡すだけなら generator を優先する。

```python
# prefer
active_user_ids = [user.id for user in users if user.is_active]
if any(user.is_active for user in users):
    ...

# avoid
results = [
    transform_user(user)
    for team in teams
    for user in team.members
    if user.is_active and user.profile is not None and user.role in allowed_roles
]
```

## 構文の選び方

- 新しめ構文や式ベースの構文は、短く書けることより意図が早く読めることを優先する。
- `lambda`、walrus、`match` / `case` は、それぞれ読みやすさが上がる場面に限定する。

```python
# prefer
sorted_users = sorted(users, key=lambda user: user.last_name)
if (match := pattern.search(text)) is None:
    return None
return match.group(1)

# avoid
if (match := pattern.search(text)) and (user := load_user(match.group(1))):
    activate_user(user)

# prefer
match event["type"]:
    case "created":
        handle_created(event)
    case "deleted":
        handle_deleted(event)
    case _:
        log_unknown_event(event)
```

## import と API 境界

- import 時に副作用が走る初期化を増やさず、実行は明示的な関数やエントリポイントに閉じる。
- `from x import *` は避け、呼び出し側が依存を追える import にする。
- 公開 API を増やすのは、他モジュールから使う責務が明確な場合だけにする。
- ヘルパー分割は、責務が明確になり再利用や読解負荷の改善があるときだけ行う。

## 避けたいこと

- 理由の薄いクラス化でデータの流れを見えにくくすること
- 暗黙のグローバル状態や import 順依存を増やすこと
- 好みだけで共通化して、引数や抽象化の層を増やすこと
- 捕捉対象を絞らない `except Exception:` を安易に増やすこと
