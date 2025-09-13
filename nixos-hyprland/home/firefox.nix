{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {
      "safe" = {
        id = 0;
        isDefault = true;
        settings = {
          "gfx.webrender.all" = true;
          # "gfx.webrender.fallback.software" = false;
          # "gfx.webgpu.ignore-blocklist" = true;
          # "gfx.webrender.compositor.force-enabled" = true;
          # "layers.gpu-process.enabled" = true;
          # "layers.acceleration.force-enabled" = true;
          # "layers.gpu-process.force-enabled" = true;
          # "webgl.force-enabled" = true;
          # "webgl.msaa-force" = true;
          # "dom.webgpu.workers.enabled" = true;
          # "dom.ipc.processCount" = 4;
          # "dom.webgpu.enabled" = true;
          # "media.hardware-video-decoding.force-enabled" = true;
          # "media.rdd-ffvpx.enabled" = false;
          # "media.utility-ffvpx.enabled" = false;
          # "media.gpu-process-decoder" = true;
          # "media.av1.enabled" = false;
          "browser.cache.disk.enable" = false;
          # "extensions.pocket.enabled" = false;
          "widget.gtk.global-menu.wayland.enabled" = true;
        };
        extensions = {
          force = false;

        };
      };
    };
    languagePacks = [
      "en-US"
      "ru"
    ];
    policies = {
      DefaultDownloadDirectory = "\${home}/Downloads";
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
    };

  };

}
