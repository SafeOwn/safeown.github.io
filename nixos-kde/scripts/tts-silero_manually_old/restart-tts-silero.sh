#!/usr/bin/env bash
pkill -f silero-v5-server 2>/dev/null
sleep 2

cd ~
export LD_LIBRARY_PATH=/nix/store/ysdkxvcvy2sy36sqigkyqanixm76z2xh-gcc-14.3.0-lib/lib:$LD_LIBRARY_PATH
~/silero-tts-env-311/bin/python silero-v5-server.py > /tmp/silero-v5.log 2>&1 &

sleep 30
tail -20 /tmp/silero-v5.log
