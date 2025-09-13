{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.hypridle = {
    # package = pkgs.hypridle;
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || (hyprlock && sleep 3)";
        # unlock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        # after_sleep_cmd = "loginctl unlock-session";
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        inhibit_sleep = 2;
      };
      # dpms
      listener = [
        # Backlight
        # {
        #   timeout = 3;
        #   on-timeout = "brightnessctl set 10";
        #   on-resume = "brightnessctl -r";
        # }

        # Keyboard Backlight
        {
          timeout = 30;
          # on-timeout = "asusctl -k off";
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd asus::kbd_backlight set 0";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd asus::kbd_backlight";

        }

        # BlackScreen
        {
          timeout = 120;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }

        # Screenlock
        {
          timeout = 180;
          on-timeout = "loginctl lock-session";
          # on-resume = notify-send "Welcome back to your desktop!"
        }

        # Suspend
        {
          timeout = 200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
