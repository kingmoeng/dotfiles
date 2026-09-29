#!/usr/bin/env bash
# dotfiles를 홈 디렉터리에 심볼릭 링크로 연결한다.
# 여러 번 실행해도 안전하며, 기존 파일은 ~/.dotfiles-backup/ 으로 옮긴다.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$DOTFILES_DIR/$1"
  local dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  = $dst (이미 연결됨)"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  ! $dst -> 백업: $BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "  + $dst"
}

echo "dotfiles: $DOTFILES_DIR"
echo

echo "[공통 / zsh / vim / tmux]"
link shellrc   "$HOME/.shellrc"
link zshrc     "$HOME/.zshrc"
link vimrc     "$HOME/.vimrc"
# tmux 3.1+ 는 ~/.config/tmux/tmux.conf 도 읽지만, 오래된 서버까지 생각하면
# ~/.tmux.conf 가 무난하다. 경로를 바꾸면 tmux.conf 의 bind r 도 같이 고칠 것.
link tmux.conf "$HOME/.tmux.conf"

echo
echo "[bash]"
# Fedora/RHEL 계열의 ~/.bashrc는 ~/.bashrc.d/*를 자동으로 읽는다.
# 이 경우 ~/.bashrc를 건드리지 않고 드롭인 파일만 넣으면 된다.
if grep -q 'bashrc\.d' "$HOME/.bashrc" 2>/dev/null; then
  link shellrc "$HOME/.bashrc.d/00-shellrc.sh"
else
  # 드롭인을 지원하지 않는 배포판(Ubuntu/WSL, macOS)은 .bashrc에 한 줄 추가
  if grep -qF '# >>> dotfiles >>>' "$HOME/.bashrc" 2>/dev/null; then
    echo "  = ~/.bashrc (이미 설정됨)"
  else
    cat >> "$HOME/.bashrc" <<'EOF'

# >>> dotfiles >>>
[ -f "$HOME/.shellrc" ] && . "$HOME/.shellrc"
# <<< dotfiles <<<
EOF
    echo "  + ~/.bashrc 에 source 구문 추가"
  fi
fi

# zsh completion 캐시 디렉터리
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"

echo
echo "[claude]"
link claude/statusline.sh "$HOME/.claude/statusline.sh"
# settings.json 은 머신별 설정(hooks, 권한 등)이 섞여 있어 링크하지 않고
# statusLine 키만 넣는다. 나머지 키는 건드리지 않는다.
settings="$HOME/.claude/settings.json"
statusline_cmd='~/.claude/statusline.sh'
if ! command -v jq >/dev/null 2>&1; then
  echo "  ! jq 가 없어 $settings 를 건너뜀 (statusline 도 jq 가 필요함)"
elif [ -f "$settings" ] && [ "$(jq -r '.statusLine.command // empty' "$settings")" = "$statusline_cmd" ]; then
  echo "  = $settings statusLine (이미 설정됨)"
else
  [ -f "$settings" ] || echo '{}' > "$settings"
  tmp="$(mktemp)"
  jq --arg cmd "$statusline_cmd" '.statusLine = {type: "command", command: $cmd}' "$settings" > "$tmp"
  cat "$tmp" > "$settings" # mv 대신 cat: 파일 권한과 심볼릭 링크를 유지
  rm -f "$tmp"
  echo "  + $settings statusLine"
fi

echo
echo "완료. 새 터미널을 열거나 'source ~/.bashrc' 로 적용하세요."
