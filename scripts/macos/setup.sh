#!/usr/bin/env bash
# macOS 環境セットアップ (chezmoi 配布対象外。手動、または chezmoi apply の run_onchange_after_install-packages から実行)。
# 用途別 install_*_stack ブロックで「何のためか」「他に何が依存か」を表す。
# 同じパッケージが複数ブロックに出てよい（既導入 skip で 2 重実行コストはほぼ無い）。
# 引数の machine profile は chezmoi の `.profile` と同じ値を取る。work では 1Password（会社管理の
# パスワード管理ツール想定）と Zotero（仕事環境では不要）を入れない。
# profile は 引数 → chezmoi の設定ファイル → 選択 の順で決める。既定値を持たせないのは、指定漏れで
# 仕事のマシンに 1Password が入るのを防ぐため。
# 設定ファイルが無ければ選んだ profile を書いておく。chezmoi init の promptChoiceOnce がこれを見つけ、
# 同じ profile をもう一度聞かない。init は .chezmoi.toml.tmpl から設定ファイルを作り直す。
set -euo pipefail

usage() {
  echo "Usage: $0 [personal|work]" >&2
  exit 1
}

# Intel の mac は対象外。Homebrew の置き場も Apple Silicon の /opt/homebrew だけを見る。
if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "Error: このスクリプトは Apple Silicon の macOS 専用です" >&2
  exit 1
fi

if [[ $# -gt 1 ]]; then
  usage
fi
chezmoi_config="$HOME/.config/chezmoi/chezmoi.toml"
machine_profile="${1:-}"
if [[ -z "$machine_profile" && -f "$chezmoi_config" ]]; then
  # .chezmoi.toml.tmpl が書く形の行だけを読む。TOML を解釈するわけではない。
  machine_profile="$(sed -nE 's/^[[:space:]]*profile = "(personal|work)"[[:space:]]*$/\1/p' "$chezmoi_config" | head -n 1)"
fi
if [[ -z "$machine_profile" ]]; then
  if [[ ! -t 0 ]]; then
    usage
  fi
  echo "Machine profile を選んでください"
  select machine_profile in personal work; do
    if [[ -n "$machine_profile" ]]; then
      break
    fi
  done
fi
if [[ "$machine_profile" != "personal" && "$machine_profile" != "work" ]]; then
  usage
fi
if [[ ! -f "$chezmoi_config" ]]; then
  mkdir -p "$(dirname "$chezmoi_config")"
  printf '[data]\n  profile = "%s"\n' "$machine_profile" >"$chezmoi_config"
fi

# PATH ではなく置き場で見る。新しいマシンでは、Homebrew があっても shell の PATH に入っていないことがある。
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "==> Homebrew をインストールします"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "Error: Homebrew のインストールに失敗しました" >&2
  exit 1
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew install は冪等だが、無駄な network / 出力を抑え差分を可視化するため
# 事前に installed list を取って skip 判定する。
installed_formulas="$(brew list --formula -1)"
installed_casks="$(brew list --cask -1)"
installed_taps="$(brew tap)"

install_if_missing() {
  local kind="$1" name="$2" installed="$3"
  # tap 経由 (user/tap/name 形式) は basename で skip 判定する (brew list は basename のみ)。
  local check="${name##*/}"
  if grep -qx "$check" <<<"$installed"; then
    echo "  - $check (skip)"
    return
  fi
  echo "  + $name"
  # 同じパッケージが後のブロックにも出るので、installed list へ足して 2 回目を skip させる。
  if [[ "$kind" == "formula" ]]; then
    brew install "$name"
    installed_formulas+=$'\n'"$check"
  else
    brew install --cask "$name"
    installed_casks+=$'\n'"$check"
  fi
}
formula() { install_if_missing formula "$1" "$installed_formulas"; }
cask()    { install_if_missing cask "$1" "$installed_casks"; }
tap() {
  local name="$1"
  if grep -qx "$name" <<<"$installed_taps"; then
    echo "  - $name (skip tap)"
    return
  fi
  echo "  + tap $name"
  brew tap "$name"
}

install_shell_stack() {
  echo "==> shell (zsh + プロンプト)"
  formula zsh
  formula zsh-autosuggestions
  formula zsh-syntax-highlighting
  formula starship
}

install_modern_cli_stack() {
  echo "==> modern CLI utilities (汎用)"
  formula bat       # cat 代替
  formula eza       # ls 代替
  formula fzf       # 汎用ファジー検索 (zsh shell integration / g() / fzf-lua)
  formula ripgrep   # 高速 grep
  formula fd        # 高速 find
  formula jq        # JSON parser
  formula zoxide    # cd 代替 (z コマンド)
}

install_git_stack() {
  echo "==> git workflow"
  formula git
  formula gh
  formula ghq
  formula lazygit
  formula prek  # pre-commit 互換 hook ランナー (Rust 製)
  formula fzf   # g() 関数 (ghq + fzf による対話的 repo 選択)
  formula bat   # g() 関数の README プレビュー (なければ ls -la fallback)
}

install_neovim_stack() {
  echo "==> neovim (純粋テキストエディタ運用)"
  formula neovim
  formula tree-sitter-cli   # nvim-treesitter main branch の parser ビルダ (tree-sitter は library のみ)
}

install_yazi_stack() {
  echo "==> yazi (terminal file manager) + プレビュー依存"
  formula yazi
  formula ffmpeg        # 動画プレビュー
  formula imagemagick   # 画像プレビュー
  formula poppler       # PDF プレビュー
  formula resvg         # SVG プレビュー
  formula sevenzip      # アーカイブプレビュー
  formula jq            # 構造化データプレビュー
  formula fd            # ファイル検索連携
  formula ripgrep       # grep 連携
  formula fzf           # ファジー連携
  formula zoxide        # cd 履歴連携
}

install_language_runtimes_stack() {
  echo "==> 言語ランタイム/版管理"
  formula nvm   # Node.js
  formula uv    # Python
}

install_dotfiles_stack() {
  echo "==> dotfiles"
  formula chezmoi
}

install_password_stack() {
  echo "==> パスワード管理"
  cask 1password
  cask 1password-cli
}

# CLI 連携と SSH agent は 1Password のアプリの設定画面でしか有効にできないため、画面を開いて待つ。
# chezmoi apply から実行された時 (CHEZMOI=1) は、利用者が画面の前にいるとは限らないので待たない。
onepassword_agent_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

onepassword_cli_ready() {
  # CLI 連携が有効なら、op はアプリでサインインしているアカウントを返す。
  local count
  count="$(op account list --format=json 2>/dev/null | jq length 2>/dev/null)" || true
  [[ "${count:-0}" -gt 0 ]]
}

onepassword_agent_ready() {
  # 0 は鍵が見えている、1 は agent はあるが鍵が無い、2 は agent に届かない。
  SSH_AUTH_SOCK="$onepassword_agent_sock" ssh-add -l >/dev/null 2>&1
}

wait_for_onepassword() {
  if [[ "${CHEZMOI:-}" == "1" ]]; then
    return
  fi
  local opened=false missing
  while true; do
    missing=""
    onepassword_cli_ready || missing+=" CLI 連携"
    onepassword_agent_ready || missing+=" SSH agent"
    if [[ -z "$missing" ]]; then
      echo "  1Password は設定済みです"
      return
    fi
    if [[ ! -t 0 ]]; then
      echo "Warning: 1Password の設定が済んでいません:$missing" >&2
      return
    fi
    if [[ "$opened" == false ]]; then
      open "onepassword://settings/developers" || true
      opened=true
      echo "  1Password で次を設定してください"
      echo "    - アカウントにサインインする"
      echo "    - Developer: Integrate with 1Password CLI"
      echo "    - Developer: Use the SSH Agent"
      echo "    - General: Keep 1Password in the menu bar と Start at login"
    fi
    echo "  未設定:$missing"
    read -r -p "  設定したら Enter を押してください (中断は Ctrl+C) " _
  done
}

install_ai_stack() {
  echo "==> AI ツール (デスクトップ)"
  cask claude
  cask chatgpt
}

install_font_stack() {
  echo "==> フォント (Nerd Font)"
  cask font-jetbrains-mono-nerd-font
  cask font-symbols-only-nerd-font
}

install_gui_utility_stack() {
  echo "==> GUI ユーティリティ"
  cask mos              # スクロール平滑化
  cask raycast          # ランチャー
}

install_maintenance_stack() {
  echo "==> Mac メンテナンス"
  formula mole                      # クリーンアップ / 最適化
  tap vjeantet/tap                  # alerter 用の個人 tap。skip 判定のため brew tap の表示名で書く
  formula vjeantet/tap/alerter      # mole 週次チェックの通知
}

install_editor_gui_stack() {
  echo "==> エディタ (GUI)"
  cask visual-studio-code
}

install_research_stack() {
  echo "==> 研究 / 文献管理"
  cask zotero
}

install_shell_stack
install_modern_cli_stack
install_git_stack
install_neovim_stack
install_yazi_stack
install_language_runtimes_stack
install_dotfiles_stack
if [[ "$machine_profile" == "personal" ]]; then
  install_password_stack
  wait_for_onepassword
fi
install_ai_stack
install_font_stack
install_gui_utility_stack
install_maintenance_stack
install_editor_gui_stack
if [[ "$machine_profile" == "personal" ]]; then
  install_research_stack
fi

echo "==> 完了しました"
