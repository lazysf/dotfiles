#!/bin/zsh
# Weekly mole dry-run -> alerter 通知。「クリーンアップ」ボタンで mo clean 実行 + 結果再通知。
# launchd (~/Library/LaunchAgents/local.mole.weekly-check.plist) から月曜 9:00 に起動。
# mole の summary 行 ("Potential space: 4.06GB | Items: 2219 | Categories: 43") を期待。

set -u
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

LOG_DIR="$HOME/Library/Logs/mole"
mkdir -p "$LOG_DIR"

mo_status=0
output=$(mo clean --dry-run 2>&1) || mo_status=$?

# mo の color 出力 (ANSI escape) を剥がしてから summary 行を tab 区切りで抽出。
parsed=$(printf '%s\n' "$output" \
  | sed -E $'s/\x1b\\[[0-9;]*m//g' \
  | sed -nE 's/^Potential space: ([^ ]+) \| Items: ([0-9]+) \| Categories: ([0-9]+)$/\1\t\2\t\3/p' \
  | head -1)

title="mole 週次チェック"

if [[ -z "$parsed" || "$mo_status" -ne 0 ]]; then
  alerter \
    --title "$title" \
    --subtitle "実行失敗 (exit ${mo_status})" \
    --message "launchd ログ参照" \
    --close-label "閉じる" \
    --timeout 300 \
    >/dev/null
  exit 1
fi

IFS=$'\t' read -r size items categories <<<"$parsed"

result=$(alerter \
  --title "$title" \
  --subtitle "解放可能 ${size}" \
  --message "${items} items / ${categories} categories" \
  --actions "クリーンアップ" \
  --close-label "閉じる" \
  --timeout 300)

[[ "$result" == "クリーンアップ" ]] || exit 0

clean_status=0
mo clean </dev/null >"$LOG_DIR/weekly-clean.log" 2>&1 || clean_status=$?

if [[ "$clean_status" -eq 0 ]]; then
  alerter \
    --title "$title" \
    --subtitle "クリーンアップ完了" \
    --message "解放見込み ${size}" \
    --close-label "閉じる" \
    --timeout 30 \
    >/dev/null
else
  alerter \
    --title "$title" \
    --subtitle "クリーンアップ失敗 (exit ${clean_status})" \
    --message "${LOG_DIR}/weekly-clean.log 参照" \
    --close-label "閉じる" \
    --timeout 60 \
    >/dev/null
  exit "$clean_status"
fi
