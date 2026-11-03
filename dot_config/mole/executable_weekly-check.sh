#!/bin/zsh
# Weekly mole dry-run -> alerter 通知。「クリーンアップ」ボタンで mo clean 実行 + 結果再通知。
# launchd (~/Library/LaunchAgents/local.mole.weekly-check.plist) から月曜 12:00 に起動。
# mole の summary 行 ("Potential space: 5.10GB · 203 items") を期待。件数が 0 だと " · N items" は出ない。

set -u
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/bin:/bin"

LOG_DIR="$HOME/Library/Logs/mole"
mkdir -p "$LOG_DIR"

# 離席中に通知が出て timeout で消えないよう、操作が戻るまで待ってから始める。
# HIDIdleTime は最後のキーボード / マウス操作からの経過 ns。取れない時は待たずに進む。
# 18 時で打ち切る。待ち続けると、実行中扱いのまま翌週の起動を launchd が飛ばすため。
idle_seconds() {
  /usr/sbin/ioreg -r -c IOHIDSystem -d 1 -k HIDIdleTime \
    | awk '/HIDIdleTime/ { print int($NF / 1000000000); exit }'
}

while true; do
  idle=$(idle_seconds)
  if [[ -z "$idle" ]]; then
    echo "$(date '+%F %T') HIDIdleTime を取得できないため待たずに進む" >&2
    break
  fi
  (( idle < 60 )) && break
  if (( $(date +%H) >= 18 )); then
    echo "$(date '+%F %T') 18 時まで操作が無かったため今週の通知を見送った"
    exit 0
  fi
  sleep 60
done

mo_status=0
output=$(mo clean --dry-run 2>&1) || mo_status=$?

# mo の color 出力 (ANSI escape) を剥がしてから summary 行を tab 区切りで抽出。
parsed=$(printf '%s\n' "$output" \
  | sed -E $'s/\x1b\\[[0-9;]*m//g' \
  | sed -nE 's/^Potential space: ([^ ]+)( · ([0-9]+) items?)?$/\1\t\3/p' \
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

IFS=$'\t' read -r size items <<<"$parsed"

result=$(alerter \
  --title "$title" \
  --subtitle "解放可能 ${size}" \
  --message "${items:-0} items" \
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
