{
  programs.mpv = {
    enable = true;
    config = {
      ytdl-format = "bestvideo+bestaudio";
      hwdec = "auto";
      hwdec-codecs = "all";
      profile = "gpu-hq";
      vo = "gpu";
      gpu-api = "opengl";
    };
    bindings = {
      "=" = "add video-zoom 0.1";
      "-" = "add video-zoom -0.1";
      "alt+=" = "add video-rotate 90";
      "alt+-" = "add video-rotate -90";
    };
  };
}
