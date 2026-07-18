#!/usr/bin/env bash
# Просто "барьер" с паролем
pkexec bash -c 'true' || exit 1

ENABLE_HDR_WSI=1 mpv \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --gpu-context=waylandvk \
    --target-colorspace-hint=yes \
    \
    --prefetch-playlist=yes \
    --hwdec=nvdec-copy \
    --msg-level=ytdl_hook=debug \
    --playlist='/home/safe/.config/mpv/`playlist/playlist_vk_adult.txt'
