# dotfiles

macOS / Fedora / WSL2 에서 공유하는 셸·vim·tmux 설정.

## 구조

| 파일 | 연결 위치 | 내용 |
|---|---|---|
| `shellrc` | `~/.shellrc` | **bash/zsh 공통.** PATH, 환경변수, alias. POSIX sh 문법만 사용 |
| `zshrc` | `~/.zshrc` | zsh 전용. 프롬프트, 히스토리, 자동완성, 키바인딩, 플러그인 |
| `vimrc` | `~/.vimrc` | vim 설정 |
| `tmux.conf` | `~/.tmux.conf` | tmux 설정. prefix, 분할·세션 키, 마우스, 스크롤백 |
| `install.sh` | — | 위 파일들을 심볼릭 링크로 연결 |

`shellrc`는 bash에서도 읽힌다. Fedora 계열은 `~/.bashrc.d/00-shellrc.sh` 드롭인으로,
그 외 배포판은 `~/.bashrc` 끝에 `source` 한 줄을 추가하는 방식으로 연결된다.
따라서 **셸을 zsh에서 bash로 되돌려도 alias와 PATH는 그대로 유지된다.**

## 새 머신에 설치

```sh
git clone <저장소 URL> ~/dotfiles
~/dotfiles/install.sh
```

기존 파일은 `~/.dotfiles-backup/<타임스탬프>/` 로 백업된다. 여러 번 실행해도 안전하다.

### 필요한 패키지

```sh
# Fedora
sudo dnf install zsh zsh-autosuggestions vim-enhanced tmux

# macOS
brew install zsh-autosuggestions tmux

# Debian/Ubuntu (WSL2)
sudo apt install zsh zsh-autosuggestions vim tmux
```

### 기본 셸 변경

바로 바꾸지 말고 `zsh` 를 직접 실행해 며칠 써 본 뒤 결정할 것.

```sh
chsh -s /bin/zsh    # 되돌리기: chsh -s /bin/bash
```

재로그인해야 적용된다. root 계정의 셸은 바꾸지 않는다.

## 머신 전용 설정

저장소에 커밋하면 안 되는 것(회사 설정, 토큰, 특정 머신 경로)은 아래 파일에 둔다.
각 설정 파일 마지막에서 자동으로 읽으며, 없으면 무시한다.

- `~/.shellrc.local` — bash/zsh 공통
- `~/.zshrc.local` — zsh 전용
- `~/.vimrc.local` — vim 전용
- `~/.tmux.conf.local` — tmux 전용

`shellrc` 안에서 `$DOTFILES_OS` (`macos` / `linux` / `wsl`) 로 OS 분기가 가능하다.

## tmux

prefix 가 **`Ctrl+b` → `Ctrl+Space`** 로 바뀐다. 새로 추가한 키는 아래가 전부고,
나머지는 tmux 기본 키 그대로다.

| 단축키 | 동작 |
|---|---|
| `prefix Ctrl+Space` | 안쪽 프로그램에 `Ctrl+Space` 전달 (원격 tmux 안에서 prefix 쓸 때) |
| `prefix \|` / `prefix -` | 좌우 / 상하 분할 |
| `prefix % " c` | 기본 키 그대로. 다만 현재 폴더에서 열린다 |
| `prefix J` | 다른 창·판을 목록에서 골라 현재 화면 오른쪽에 합치기 |
| `prefix S` | 이름 입력 후 새 세션 생성과 전환 |
| `prefix X` | 현재 세션 종료 (확인 후) |
| `prefix r` | 설정 다시 불러오기 |

기본 키 중 자주 쓰는 것: `s` `w` 세션/창 트리 · `(` `)` 이전/다음 세션 · `$` 세션 이름 변경 ·
`d` 빠져나오기 · `z` 판 크게 보기 · `!` 판을 창으로 떼기 · `q` 판 번호 보고 이동 ·
`Space` 배치 전환 · `[` 복사 모드(vi 키: `hjkl` 이동, `v` 선택, `y` 복사).

이미 떠 있는 tmux 에는 `tmux source-file ~/.tmux.conf` 로 적용되지만,
prefix 와 base-index 는 새 세션부터 확실히 반영되므로 한 번 다 끄고 다시 띄우는 게 깔끔하다.

## 메모

- **`ls` 색상 옵션은 OS마다 다르다.** BSD(macOS)는 `ls -G`, GNU(Linux)는 `ls --color=auto`.
  GNU에서 `-G`는 색상이 아니라 "그룹 열 숨기기"라 조용히 다르게 동작한다. `shellrc`에서 분기 처리함.
- **플러그인 매니저(antidote)를 쓰지 않는다.** 플러그인이 1~2개뿐이라 배포판 패키지로 설치하고
  `source` 한 줄 하는 편이 디버깅할 레이어가 적다.
- **`zsh-syntax-highlighting`은 일부러 뺐다.** 키 입력마다 명령줄 전체를 재파싱해 긴 줄에서
  느려진다. 필요하면 `zshrc`의 주석 블록을 풀 것.
- **nvm은 셸 시작을 ~100ms 늦춘다.** 안 쓰게 되면 `shellrc`의 nvm 블록을 지울 것.
- **tmux prefix `Ctrl+Space`는 입력기와 겹친다.** macOS는 시스템 설정 → 키보드 → 단축키 →
  입력 소스에서, 리눅스는 IBus 설정에서 입력 소스 전환 단축키를 먼저 꺼야 한다.
- **`tmux-256color` terminfo가 없는 서버가 있다.** 그대로 두면 색이 깨지거나
  "missing or unsuitable terminal" 경고가 뜬다. `tmux.conf`에서 `infocmp`로 확인해
  없으면 `screen-256color`로 떨어지게 분기해 뒀다.
- **tmux `mouse on` 상태의 드래그는 tmux 복사 모드다.** 터미널 자체의 선택 기능을
  쓰려면 Shift를 누른 채 드래그할 것.
