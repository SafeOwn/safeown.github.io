{
  programs.rio = {
    enable = true;
    settings = {
      # editor = "hx";

      hide-mouse-cursor-when-typing = true;
      renderer = {
        performance = "Low";
        backend = "Automatic";
        disable-unfocused-render = true;
      };

      # colors = {

      #   background = "#1b1b1b";
      #   foreground = "#ebdbb2";
      #   selection-background = "#665c54";
      #   selection-foreground = "#ebdbb2";
      #   cursor = "#ebdbb2";
      #   black = "#1b1b1b";
      #   red = "#cc241d";
      #   green = "#98971a";
      #   yellow = "#d79921";
      #   blue = "#458588";
      #   magenta = "#b16286";
      #   cyan = "#689d6a";
      #   white = "#a89984";
      #   light_black = "#928374";
      #   light_red = "#fb4934";
      #   light_green = "#b8bb26";
      #   light_yellow = "#fabd2f";
      #   light_blue = "#83a598";
      #   light_magenta = "#d3869b";
      #   light_cyan = "#8ec07c";
      #   light_white = "#ebdbb2";

      # };
      # fonts = {
      #   size = 19;
      #   family = "JetBrainsMono Nerd Font Mono";
      #   hinting = true;
      #   regular = {
      #     family = "JetBrainsMono Nerd Font Mono";
      #     style = "Normal";
      #     weight = 400;
      #   };
      #   blod = {
      #     family = "JetBrainsMono Nerd Font Mono";
      #     style = "Normal";
      #     weight = 800;
      #   };
      #   italic = {
      #     family = "JetBrainsMono Nerd Font Mono";
      #     style = "Italic";
      #     weight = 400;
      #   };
      #   bold-italic = {
      #     family = "JetBrainsMono Nerd Font Mono";
      #     style = "Italic";
      #     weight = 800;
      #   };
      #   emoji = {
      #     family = "Noto Color Emoji";
      #   };
      # };
      cursor = {
        shape = "block";
        blinking = true;
        blinking-interval = 800;
      };
      navigation = {
        use-split = true;
        mode = "BottomTab";
        clickable = true;
        hide-if-single = false;
      };
      # bindings = {
      #   keys = [
      #     {
      #       key = "r";
      #       "with" = "control | shift";
      #       action = "SplitRigh";
      #     }
      #   ];
      # };
      confirm-before-quit = true;

    };
  };
}
