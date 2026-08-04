# dotfiles

macOS / Fedora / WSL2 에서 공유하는 셸·vim 설정.

## 구조

| 파일 | 연결 위치 | 내용 |
|---|---|---|
| `shellrc` | `~/.shellrc` | **bash/zsh 공통.** PATH, 환경변수, alias. POSIX sh 문법만 사용 |
| `zshrc` | `~/.zshrc` | zsh 전용. 프롬프트, 히스토리, 자동완성, 키바인딩, 플러그인 |
| `vimrc` | `~/.vimrc` | vim 설정 |
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
sudo dnf install zsh zsh-autosuggestions vim-enhanced

# macOS
brew install zsh-autosuggestions

# Debian/Ubuntu (WSL2)
sudo apt install zsh zsh-autosuggestions vim
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

`shellrc` 안에서 `$DOTFILES_OS` (`macos` / `linux` / `wsl`) 로 OS 분기가 가능하다.

## 메모

- **`ls` 색상 옵션은 OS마다 다르다.** BSD(macOS)는 `ls -G`, GNU(Linux)는 `ls --color=auto`.
  GNU에서 `-G`는 색상이 아니라 "그룹 열 숨기기"라 조용히 다르게 동작한다. `shellrc`에서 분기 처리함.
- **플러그인 매니저(antidote)를 쓰지 않는다.** 플러그인이 1~2개뿐이라 배포판 패키지로 설치하고
  `source` 한 줄 하는 편이 디버깅할 레이어가 적다.
- **`zsh-syntax-highlighting`은 일부러 뺐다.** 키 입력마다 명령줄 전체를 재파싱해 긴 줄에서
  느려진다. 필요하면 `zshrc`의 주석 블록을 풀 것.
- **nvm은 셸 시작을 ~100ms 늦춘다.** 안 쓰게 되면 `shellrc`의 nvm 블록을 지울 것.
