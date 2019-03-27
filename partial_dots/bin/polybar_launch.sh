#!/usr/bin/env bash

#
# Source: https://github.com/jaagr/polybar/issues/763#issuecomment-331604987
#

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload manual &
  done
else
  polybar --reload manual &
fi
