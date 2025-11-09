#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint \
    \
    --hwdec \
    --msg-level=ytdl_hook=debug \
    --playlist=https://safeown.github.io/plvideo_4k_final.m3u
