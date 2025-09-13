{
  lib,
  osConfig,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # ./hyprland-env.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.variables = [ "--all" ];
    xwayland.enable = false;
    settings = {
      # Some default env vars.
      env = [
        # "GTK_THEME, Gruvbox-Dark"
        # "HYPRCURSOR_THEME,Bibata Modern Classic"
        # "HYPRCURSOR_SIZE,28"
        # "XCURSOR_THEME,Bibata Modern Classic"
        # "XCURSOR_SIZE,28"
        "HYPRLAND_TRACE=0"
        "WAYLAND_DISPLAY,wayland-1"
        # "WLR_NO_HARDWARE_CURSORS,1"
        # "WLR_RENDERER_ALLOW_SOFTWARE,1"
        # "WLR_RENDERER,vulkan"
        # "QT_QPA_PLATFORMTHEME,qt6ct" # change to qt6ct if you have that
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_SCALE_FACTOR,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORMTHEME,gtk3"
        "GDK_SCALE,1"
        "GDK_USE_PORTAL,1"
        "GDK_BACKEND,wayland"
        "CLUTTER_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"
        # "ECORE_EVAS_ENGINE,wayland"
        # "ELM_ENGINE,wayland"
        # "ELM_ACCEL,opengl"
        "WINIT_UNIX_BACKEND,wayland"
        # "_JAVA_AWT_WM_NONREPARENTING,1"
      ];

      # See https://wiki.hyprland.org/Configuring/Monitors/

      # "monitor" = ",preferred,auto,1,mirror, HDMI-A-1";
      monitor = [ "eDP-1, 1920x1200@60.00100, 0x0, 1, transform, 0" ];

      # Execute your favorite apps at launch
      exec-once = [
        # "dbus-update-activation-environment --systemd --all"
        # "iio-hyprland"
        # "systemctl --user start hyprpolkitagent"
        # "soteria"
        "hyprland-per-window-layout"
        # "clipse -listen"
        "wl-clip-persist --clipboard both"
        # "source" = "~/.config/hypr/myColors.conf";
      ];

      # Set programs that you use
      "$terminal" = "ghostty";
      "$fileManager" = "ghostty -e yazi";
      "$edit" = "ghostty -e hx";
      "$menu" = "pkill wofi || wofi";
      "$browser" = "firefox";
      "$telegram" = "telegram-desktop";

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/

      input = {
        kb_layout = "us,ru";
        # kb_variant =
        # kb_model = "asus-keyboard-2";
        # kb_options = "grp:caps_toggle";
        kb_options = "grp:win_space_toggle";
        repeat_rate = 50;
        repeat_delay = 500;
        follow_mouse = 0;

        touchpad = {
          # name = "asuf1204:00-2808:0201-touchpad";
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };

        sensitivity = 0.25; # -1.0 - 1.0, 0 means no modification.
      };

      debug = {
        disable_logs = true;
        damage_tracking = 0;
      };

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 1;
        gaps_out = 1;
        border_size = 2;
        #  "col.active_border" = lib.mkForce "rgb(${config.stylix.base16Scheme.base0A})";
        # "col.inactive_border" = "rgba(595959aa)";
        #"col.active_border" = "rgba(fabd2fBF)";
        #"col.inactive_border" = "rgba(573F14e5)";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10;

        blur = {
          enabled = false;
          # size = 3;
          # passes = 1;
        };
        shadow = {
          enabled = false;
        };
        # drop_shadow = false;
        # shadow_range = 4;
        # shadow_render_power = 3;
        #"col.shadow" = "rgba(1d202199)";
      };

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
      animations = {
        enabled = false;

        # bezier = myBezier, 0.05, 0.9, 0.1, 1.05;

        # animation = windows, 1, 7, myBezier;
        # animation = windowsOut, 1, 7, default, popin 80%;
        # animation = border, 1, 10, default;
        # animation = borderangle, 1, 8, default;
        # animation = fade, 1, 7, default;
        # animation = workspaces, 1, 6, default;
      };

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/
      dwindle = {
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      # master = {
      #   new_is_master = true;
      #  };

      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      gestures = {
        workspace_swipe = true;
      };

      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true;
        mouse_move_enables_dpms = true;
        vfr = true;
      };

      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      #    device:epic-mouse-v1 = {
      #    sensitivity = -0.5;
      # };

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # windowrulev2 = nomaximizerequest, class:.* # You ll probably like this.

      windowrulev2 = [
        "center,class:(pc.tray-tui)"
        "float,class:(pc.tray-tui)"
        "size 800 800,class:(pc.tray-tui)"
        "center,class:(pc.clipse)"
        "float,class:(pc.clipse)"
        "size 800 800,class:(pc.clipse)"
        "center,class:(pc.impala)"
        "float,class:(pc.impala)"
        "size 800 800,class:(pc.impala)"
        "center,class:(pc.btop)"
        "float,class:(pc.btop)"
        "size 1100 800,class:(pc.btop)"
        "center,class:(pc.bluetui)"
        "float,class:(pc.bluetui)"
        "size 800 800,class:(pc.bluetui)"
        "center,class:(pc.gtt)"
        "float,class:(pc.gtt)"
        "size 1100 800,class:(pc.gtt)"
        "center,class:(pc.tjournal)"
        "float,class:(pc.tjournal)"
        "size 1100 800,class:(pc.tjournal)"
        "center,class:(pc.wiremix)"
        "float,class:(pc.wiremix)"
        "size 1100 500,class:(pc.wiremix)"
      ];

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mainMod" = "SUPER";

      # lock screen if lid is closed
      # bindl = ", switch:Lid Switch , exec , loginctl lock-session";

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/
      bind = [
        #"$mainMod, V, exec, cliphist list | ( pkill wofi ||  wofi --dmenu  ) | cliphist decode | wl-copy"
        # "$mainMod, V, exec, pkill clipse || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class clipse -e 'clipse'"

        "$mainMod, Q, exec, $terminal"
        "$mainMod, F,  exec, $browser"
        "$mainMod, I,  exec, $telegram"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, H, exec, $edit"
        # "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle

        # ghostty
        "$mainMod, V, exec, pkill clipse || ghostty --class=pc.clipse -e clipse"
        "$mainMod, B, exec, pkill bluetuith || ghostty --class=pc.bluetui -e bluetui"
        "$mainMod, W, exec, pkill impala || ghostty --class=pc.impala -e impala"
        "$mainMod, T, exec, pkill gtt || ghostty --class=pc.gtt -e gtt"
        "$mainMod, N, exec, pkill tjournal || ghostty --class=pc.tjournal -e tjournal"

        # wezterm
        # "$mainMod, V, exec, pkill clipse || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class clipse -e clipse"
        # "$mainMod, B, exec, pkill bluetui || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class bluetui -e bluetui"
        # "$mainMod, W, exec, pkill impala || wezterm  --config hide_tab_bar_if_only_one_tab=true -e --class impala -e impala"
        # "$mainMod, T, exec, pkill gtt || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class gtt -e 'gtt'"
        # "$mainMod, N, exec, pkill tjournal || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class tjournal -e tjournal"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod , 1     , workspace , 1"
        "$mainMod , 2     , workspace , 2"
        "$mainMod , 3     , workspace , 3"
        "$mainMod , 4     , workspace , 4"
        "$mainMod , 5     , workspace , 5"
        "$mainMod , 6     , workspace , 6"
        "$mainMod , 7     , workspace , 7"
        "$mainMod , 8     , workspace , 8"
        "$mainMod , 9     , workspace , 9"
        "$mainMod , 0     , workspace , 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT , 1 , movetoworkspace , 1"
        "$mainMod SHIFT , 2 , movetoworkspace , 2"
        "$mainMod SHIFT , 3 , movetoworkspace , 3"
        "$mainMod SHIFT , 4 , movetoworkspace , 4"
        "$mainMod SHIFT , 5 , movetoworkspace , 5"
        "$mainMod SHIFT , 6 , movetoworkspace , 6"
        "$mainMod SHIFT , 7 , movetoworkspace , 7"
        "$mainMod SHIFT , 8 , movetoworkspace , 8"
        "$mainMod SHIFT , 9 , movetoworkspace , 9"
        "$mainMod SHIFT , 0 , movetoworkspace , 10"

        # Move active window in workspace
        "$mainMod ALT , left  , movewindow, l"
        "$mainMod ALT , right , movewindow, r"
        "$mainMod ALT , up    , movewindow, u"
        "$mainMod ALT , down  , movewindow, d"

        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, SPACE, exec, sh /etc/nixos/script/layout.sh"
        # Fn keys
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ #&& /home/safe/.config/mako/scripts/show_volume.sh"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- #&& /home/safe/.config/mako/scripts/show_volume.sh"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle #&& /home/safe/.config/mako/scripts/show_mute.sh"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle #&& /home/safe/.config/mako/scripts/show_mute.sh"

        ", XF86KbdBrightnessUp, exec, brightnessctl -d *::kbd_backlight set 33%+"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d *::kbd_backlight set 33%-"

        ", XF86MonBrightnessUp, exec, brightnessctl set 1%+  # && /home/teapot293/.config/dunst/scripts/show_brightness.sh"
        ", XF86MonBrightnessDown, exec, brightnessctl set 1%- # && /home/teapot293/.config/dunst/scripts/show_brightness.sh"

        # ", XF86Launch1, exec, pkill slurp | pkill satty || grimblast --freeze save screen - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%Ih%Mm%Ss').png"
        ", XF86Launch1, exec, pkill grim | pkill satty || grim - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"
        ", XF86Launch3, exec, pkill hyprsunset || hyprsunset -t 5000"
        ", XF86Launch4, exec, asusctl profile -n;pkill -SIGRTMIN+1 waybar"

        ", XF86TouchpadToggle, exec, sh /etc/nixos/script/touchPadToggle.sh"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
