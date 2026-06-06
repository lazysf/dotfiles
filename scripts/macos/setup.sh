#!/usr/bin/env bash
# macOS 環境セットアップ: Homebrew を導入し、Brewfile のパッケージを一括適用する。
# 実行: scripts/setup.sh （chezmoi 配布対象外。手動で叩く）
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: このスクリプトは macOS 専用です" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${SCRIPT_DIR}/Brewfile"

# Homebrew が未導入ならインストールする。
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Homebrew をインストールします"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew を現在のシェルから使えるようにする（Apple Silicon / Intel 両対応）。
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Error: Homebrew のインストールに失敗しました" >&2
  exit 1
fi

# Brewfile のパッケージを適用する。
echo "==> Brewfile を適用します: ${BREWFILE}"
brew bundle --file="${BREWFILE}"

echo "==> 完了しました"
