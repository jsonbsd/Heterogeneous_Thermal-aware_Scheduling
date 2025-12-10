#!/bin/bash

# cores
BIG1=80
BIG1MID1=C0
BIG1MID2=E0
BIG1MID3=F0
MID1=40
MID2=60
MID3=70
LIT1=08
LIT2=0C
LIT3=0E
LIT4=0F

MIDA=40
MIDB=20
MIDC=10

LITA=08
LITB=04
LITC=02
LITD=01

# Modifiable parameters
BIG_freq_threshold=1885000              # 1.885 GHz
sampling_interval_s=0.1                 # 100 ms

exe=cjpeg

while :; do
    pid="$(pidof "$exe" 2>/dev/null | awk '{print $1}')"
    [ -n "$pid" ] && break
    sleep "$sampling_interval_s"
done

echo "$exe starts. Monitoring BIG core frequency..."

while :; do
  freq_line="$(cat /sys/devices/platform/exynos-acme/fw_freq | grep 'cpu7')"
  freq="$(echo "$freq_line" | awk '{print $3}')"
  freq="${freq:-0}"
  freq=$(echo "$freq" | tr -cd '0-9')

  if [ -n "$freq" ] && [ "$freq" -lt "$BIG_freq_threshold" ]; then
    taskset -ap "$MIDC" "$pid" > /dev/null
    echo "Migration completed."
    break
  fi

  sleep "$sampling_interval_s"
done