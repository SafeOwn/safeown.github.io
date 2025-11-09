#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint \
    \
    --prefetch-playlist=yes \
    --msg-level=EPGTV=debug \
    --hwdec \
    --msg-level=ytdl_hook=debug \
    --playlist=https://safeown.github.io/autoIPTV/IPTVSHARED/TOPPEHT_TB.m3u



