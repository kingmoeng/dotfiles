# ~/.zshrc — zsh 대화형 셸 설정
# PATH / alias / 환경변수는 여기 두지 말고 shellrc(공통)에 둔다.

# 공통 설정 먼저 로드
[ -f "$HOME/.shellrc" ] && source "$HOME/.shellrc"

# ------------------------------------------------------------------ 프롬프트
# 세 머신의 사용자 이름이 같아서 %n 대신 머신 태그를 색으로 구분한다.
# 셸 시작 시 한 번만 계산된다. 태그/색을 바꾸려면 ~/.shellrc.local 에서
# PROMPT_HOST_TAG / PROMPT_HOST_COLOR 를 지정한다.
case $DOTFILES_OS in
  macos) : ${PROMPT_HOST_TAG:=mac} ${PROMPT_HOST_COLOR:=magenta} ;;
  wsl)   : ${PROMPT_HOST_TAG:=wsl} ${PROMPT_HOST_COLOR:=blue} ;;
  linux) : ${PROMPT_HOST_TAG:=$(. /etc/os-release 2>/dev/null && echo ${ID:-linux})} \
           ${PROMPT_HOST_COLOR:=green} ;;
  *)     : ${PROMPT_HOST_TAG:=%m} ${PROMPT_HOST_COLOR:=white} ;;
esac
# source ~/.zshrc 를 다시 해도 ssh: 가 중복으로 붙지 않게 임시 변수에 조립한다.
_tag=$PROMPT_HOST_TAG
[[ -n $SSH_CONNECTION ]] && _tag="ssh:$_tag"
PROMPT="%F{$PROMPT_HOST_COLOR}%B${_tag}%b%f %F{yellow}%~%f > "
unset _tag

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

# ------------------------------------------------------------------ 자동 업데이트
# 하루 한 번(20시간 간격) 백그라운드에서 이 저장소를 fast-forward 하고, 결과는 다음 셸 시작 때
# 한 번만 알린다. 로컬 수정이 있거나 원격과 갈라졌으면 건드리지 않고 알리기만 한다.
# 오프라인 등으로 fetch 가 실패하면 조용히 넘어가고 다음 날 다시 시도한다.
() {
  local repo=${${(%):-%x}:A:h}          # 심볼릭 링크를 따라간 실제 저장소 위치
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}
  local stamp=$cache/dotfiles-update msg=$cache/dotfiles-update.msg

  if [[ -s $msg ]]; then
    print -r -- "$(<$msg)"
    rm -f $msg
  fi

  local fresh=($stamp(Nmh-20))          # 20시간 안에 확인했으면 건너뜀 (매일 비슷한 시각에 켜도 하루 한 번 돌도록 여유를 둠)
  (( $#fresh )) && return
  mkdir -p $cache && touch $stamp

  (
    cd $repo || exit
    # 인증이 필요해지면(비공개 전환, SSH 원격 등) 묻지 말고 바로 실패하게 한다.
    export GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes'
    if [[ -n $(git status --porcelain) ]]; then
      print -r -- "dotfiles: 로컬 수정이 있어 업데이트 건너뜀 ($repo 에서 git status 확인)" > $msg
      exit
    fi
    git fetch -q || exit
    git merge-base --is-ancestor @{u} HEAD && exit   # 받을 것이 없음
    local old=$(git rev-parse HEAD)
    if ! git merge -q --ff-only @{u}; then
      print -r -- "dotfiles: 원격과 갈라져서 수동 처리 필요 ($repo)" > $msg
      exit
    fi
    local new=$(git rev-parse HEAD)
    {
      print -r -- "dotfiles: $(git rev-list --count $old..$new)개 커밋 반영 (${old:0:7}..${new:0:7})"
      # 링크를 추가·변경하려면 반드시 install.sh 를 고쳐야 하므로 그것만 보면 된다.
      git diff --quiet $old $new -- install.sh || print -r -- "└ install.sh 가 바뀌었으니 다시 실행할 것"
    } > $msg
  ) &>/dev/null &!
}

# ------------------------------------------------------------------ 머신 전용
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
