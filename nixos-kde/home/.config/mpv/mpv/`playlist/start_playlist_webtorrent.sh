#!/usr/bin/env bash

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint=yes \
    \
    --prefetch-playlist=yes \
    --hwdec=nvdec-copy \
    --msg-level=ytdl_hook=debug \
    1.torrent



