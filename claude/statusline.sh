#!/bin/sh
# Claude Code statusline. stdin으로 세션 JSON을 받아 한 줄로 출력한다.
# 예: Opus 5.5 │ context 82% left │ 5h 64% left ↻2h13m │ 7d 91% left ↻3d4h
# rate_limits 는 구독 로그인일 때만 들어오므로, 없으면 해당 칸을 생략한다.
exec jq -r '
  # 사용률(%) -> 남은 비율
  def p: if . == null then "–" else "\(100 - . | floor)% left" end;
  # 리셋 시각(epoch) -> " ↻1d2h" / " ↻3h5m" / " ↻12m"
  def r($t):
    if $t == null then ""
    else (($t - now) / 60 | floor) as $m
      | if $m <= 0 then ""
        elif $m >= 1440 then " ↻\($m / 1440 | floor)d\(($m % 1440) / 60 | floor)h"
        elif $m >= 60 then " ↻\($m / 60 | floor)h\($m % 60)m"
        else " ↻\($m)m"
        end
    end;
  [ (.model.display_name // "?"),
    "context \(.context_window.used_percentage | p)",
    (.rate_limits.five_hour // empty | "5h \(.used_percentage | p)\(r(.resets_at))"),
    (.rate_limits.seven_day // empty | "7d \(.used_percentage | p)\(r(.resets_at))")
  ] | join(" │ ")
'
