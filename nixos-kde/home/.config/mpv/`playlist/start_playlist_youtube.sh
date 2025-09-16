#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint \
    \
    --prefetch-playlist=yes \
    --ytdl-raw-options-append=proxy=http://127.0.0.1:7897 \
    --hwdec \
    --msg-level=ytdl_hook=debug \
    --playlist=playlist_youtube.txt
