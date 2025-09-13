{
  lib,
  config,
  pkgs,
  osConfig,
  inputs,
  ...
}:
{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    package = pkgs.wezterm;        # package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
      local wezterm = require 'wezterm';
      local config = wezterm.config_builder();
      local font_antialias = "Greyscale"
      --local mux = wezterm.mux
                   -- "Subpixel"
                    return {
                  use_resize_increments = false,
                  adjust_window_size_when_changing_font_size = true,
                  --  font = wezterm.font("JetBrainsMono Nerd Font Mono"),
                     show_close_tab_button_in_tabs = true,
                    front_end = "OpenGL",
                  --  front_end = "WebGpu",
                    webgpu_power_preference = "LowPower",
                   --  font_size = 13.0,
                   --  color_scheme = "GruvboxDarkHard",
                     enable_tab_bar = true,
                    -- hide_tab_bar_if_only_one_tab = true,
                     tab_bar_at_bottom = true,
                   --  enable_touch_input = true,

                   --  animation_fps = 120,
                     cursor_blink_ease_in = 'Constant',
                     cursor_blink_ease_out = 'Constant',
                     enable_wayland = true,
                     default_cursor_style = 'BlinkingBlock',
                    window_content_alignment = {
      horizontal = 'Center',
      vertical = 'Center',
       },
                   window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
      }

                   }

    '';
  };
}
