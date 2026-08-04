# ~/.zshrc — zsh 대화형 셸 설정
# PATH / alias / 환경변수는 여기 두지 말고 shellrc(공통)에 둔다.

# 공통 설정 먼저 로드
[ -f "$HOME/.shellrc" ] && source "$HOME/.shellrc"

# ------------------------------------------------------------------ 프롬프트
PROMPT='%F{cyan}%n%f %F{yellow}%~%f > '

# ------------------------------------------------------------------ 히스토리
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS        # 연속 중복 저장 안 함
setopt HIST_IGNORE_ALL_DUPS    # 전체 히스토리에서 중복 제거
setopt HIST_SAVE_NO_DUPS       # 저장 시 중복 제외
setopt SHARE_HISTORY           # 여러 터미널 세션 간 히스토리 공유
setopt HIST_IGNORE_SPACE       # 앞에 스페이스 붙이면 히스토리 저장 안 됨
setopt HIST_REDUCE_BLANKS      # 불필요한 공백 제거 후 저장

setopt NO_BEEP                 # 터미널 벨 끄기

# ------------------------------------------------------------------ 자동완성
# compinit을 명시적으로 호출해야 completion 시스템이 켜진다.
# 캐시(zcompdump)를 ~/.cache에 두어 홈 디렉터리를 어지럽히지 않는다.
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # 대소문자 무시
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # 목록 색상
zstyle ':completion:*' menu select                          # 방향키로 후보 선택

# ------------------------------------------------------------------ 플러그인
# 배포판 패키지로 설치한다(Fedora: dnf install zsh-autosuggestions,
# macOS: brew install zsh-autosuggestions). 플러그인 매니저는 쓰지 않는다.
for _plugin in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  if [[ -r $_plugin ]]; then
    source $_plugin
    break
  fi
done
unset _plugin

# zsh-syntax-highlighting은 일부러 뺐다. 키 입력마다 명령줄 전체를 다시 파싱해서
# 긴 줄에서 타이핑이 느려진다. 쓰고 싶으면 패키지 설치 후 아래 주석을 풀 것.
# (반드시 다른 플러그인들보다 마지막에 source 해야 한다)
# for _p in /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
#           /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
#   [[ -r $_p ]] && source $_p && break
# done

# ------------------------------------------------------------------ 키바인딩
bindkey -e                     # emacs 키바인딩(기본값이지만 명시)

# Home/End는 터미널마다 보내는 이스케이프 시퀀스가 달라서 둘 다 등록해 둔다.
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char     # Delete
bindkey '^[[1;5C' forward-word  # Ctrl + →
bindkey '^[[1;5D' backward-word # Ctrl + ←

# ------------------------------------------------------------------ fzf
# 설치돼 있을 때만. Ctrl+R 히스토리 검색, Ctrl+T 파일 검색, Alt+C 디렉터리 이동.
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [[ -r /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
  fi
fi

# ------------------------------------------------------------------ 머신 전용
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
