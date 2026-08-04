" 이식성 (배포판마다 vim 기본값이 달라서 명시해 둔다)
set nocompatible                  " vi 호환 모드 끄기
set backspace=indent,eol,start    " 백스페이스로 들여쓰기/줄바꿈까지 지우기

" 기본 화면 설정
"set number           " 화면 왼쪽에 줄 번호 표시
set hlsearch         " 검색 결과에 하이라이트(노란색 배경) 표시
set ignorecase smartcase " 검색 시 대소문자 무시 (단, 대문자가 포함되면 대소문자 구분)

" 구문 강조
syntax on            " 코드 프로그래밍 언어별 문법 강조(하이라이트) 활성화

" 탭/들여쓰기
set tabstop=2        " 탭 너비
set shiftwidth=2     " 자동 들여쓰기 너비
set expandtab        " 탭을 스페이스로 변환

" 편의성
set cursorline       " 현재 커서 줄 하이라이트
set scrolloff=8      " 스크롤 시 커서 위아래 여백 8줄 유지
set nowrap           " 긴 줄 자동 줄바꿈 안 함
set showmatch        " 괄호 매칭 하이라이트

" 파일
set encoding=utf-8   " 파일 인코딩
set nobackup         " 백업 파일 생성 안 함
set noswapfile       " 스왑 파일 생성 안 함

" 검색
set incsearch        " 타이핑하면서 실시간 검색

" 머신 전용 설정
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
