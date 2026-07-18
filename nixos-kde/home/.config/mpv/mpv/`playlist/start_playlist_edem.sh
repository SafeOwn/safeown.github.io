#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint=yes \
    \
    --prefetch-playlist=yes \
    --msg-level=EPGTV=debug \
    --hwdec=nvdec-copy \
    --msg-level=ytdl_hook=debug \
    --no-save-position-on-quit \
    --no-resume-playback \
    --playlist=https://safeown.github.io/iptv-playlist-edem/EdemTV-main.m3u
