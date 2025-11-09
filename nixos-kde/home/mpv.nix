{
  programs.mpv = {
    enable = true;
    config = {
      # --- Ваши настройки ---
      ytdl-format = "bestvideo+bestaudio";
      hwdec = "auto";
      hwdec-codecs = "all";
      profile = "gpu-hq";
      vo = "gpu";
      gpu-api = "opengl";

      # --- Тема Gruvbox (вручную) ---
      background-color = "#1d2021";     # base00
      osd-back-color = "#3c3836";       # base01
      osd-border-color = "#3c3836";
      osd-color = "#d5c4a1";            # base05
      osd-shadow-color = "#1d2021";
      sub-color = "#d5c4a1";
      sub-border-color = "#3c3836";
      sub-shadow-color = "#1d2021";
      sub-font = "JetBrainsMono Nerd Font";
      osd-font = "JetBrainsMono Nerd Font";
    };

    bindings = {
      "=" = "add video-zoom 0.1";
      "-" = "add video-zoom -0.1";
      "alt+=" = "add video-rotate 90";
      "alt+-" = "add video-rotate -90";
    };
  };
}
