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

echo "[공통 / zsh / vim]"
link shellrc "$HOME/.shellrc"
link zshrc   "$HOME/.zshrc"
link vimrc   "$HOME/.vimrc"

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
echo "완료. 새 터미널을 열거나 'source ~/.bashrc' 로 적용하세요."
