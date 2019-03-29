#!/bin/bash

countDisplays() {
  xrandr --listactivemonitors | grep Monitor | sed -r 's/.*: ([0-9]{1,})/\1/'
}

getDisplays() {
  xrandr --listactivemonitors | grep -v Monitor | sed -r 's/.* (\S+)$/\1/' | tr '\n' ' '
}

getBrightness() {
  current=0
  for display in $(getDisplays); do
    b=$(xrandr --verbose | grep -A10 $display | grep Brightness | sed -r 's/.*: ([\.0-9]{1,})$/\1/')
    current=$(echo "$current + $b" | bc)
  done
  echo $(echo "scale=2; $current / $(countDisplays)" | bc)
}

setBrightness() {
  for display in $(getDisplays); do
    xrandr --output $display --brightness $1
  done
}

incrementBrightness() {
  level=$(echo "$(getBrightness)+0.15" | bc)
  if (( $( echo "$level > 1.00" | bc -l ) )); then
    level=1.00
  fi
  setBrightness $level
}

decrementBrightness() {
  level=$(echo "$(getBrightness)-0.15" | bc)
  if (( $( echo "$level < 0.00" | bc -l ) )); then
    level=0.00
  fi
  setBrightness $level
}

case "$1" in
"inc")
  incrementBrightness
  ;;
"dec")
  decrementBrightness
  ;;
"reset")
  setBrightness 1.00
  ;;
"off")
  setBrightness 0.00
  ;;
esac

# for i in $(xrandr | grep ' connected' | sed -r 's/^(\S+) .*/\1/'); do xrandr --output $i --brightness 1; done
