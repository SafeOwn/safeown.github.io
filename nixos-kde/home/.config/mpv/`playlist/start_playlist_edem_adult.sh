#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint \
    \
    --prefetch-playlist=yes \
    --hwdec \
    --msg-level=ytdl_hook=debug \
    --playlist=https://safeown.github.io/EdemTV-main-adult.m3u


# ENABLE_HDR_WSI=1 mpv \
#     --vo=gpu-next \
#     --gpu-api=vulkan \
#     --gpu-context=waylandvk \
#     --target-colorspace-hint \
#     \
#     --prefetch-playlist=yes \
#     --hwdec \
#     --msg-level=ytdl_hook=debug \
#     --playlist=EdemTV-main-adult.html



