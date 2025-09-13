{
  config,
  lib,
  pkgs,
  ...
}:
{
  #  imports = [ ./theme.nix ];
  programs.waybar = {
    enable = true;
    # package = pkgs.waybar;
    systemd = {
      enable = true;
      target = "config.wayland.systemd.target";
    };
    style = lib.mkAfter "
      ${builtins.readFile ./style.css}
    ";
    settings = [
      {
        layer = "top";
        #"position" = "top";
        modules-left = [
          "custom/menu"
          "hyprland/workspaces"
          "custom/window-close"
          "custom/window-full"
          # "hyprland/window"
        ];
        modules-center = [
          "hyprland/language"
          "clock"
          "idle_inhibitor"
          "custom/perfomance"
          "custom/tray"
        ];
        modules-right = [
          "pulseaudio#input"
          "pulseaudio#output"
          "bluetooth"
          "network"
          "cpu"
          "memory"
          "backlight"
          "battery"
          "group/group-power"
        ];

        "custom/menu" = {
          format = "{icon}";
          format-icons = "[ 󱄅 ]";
          on-click = "pkill wofi || wofi";
          tooltip = false;
        };
        "custom/perfomance" = {
          format = "{}";
          exec = "sh /etc/nixos/home/waybar/pp.sh";
          # "exec" = "asusctl profile -p | grep Active | awk '{print substr($NF,1,1)}'";
          on-click = "asusctl profile -n;pkill -SIGRTMIN+1 waybar";
          signal = 1;
          return-type = "json";
          tooltip = false;
          # "format-icons" = {
          #   "Quiet" = "󰛐 ";
          #   "Balanced" = "󰛑 ";
          #   "Performace" = "󰛑 ";
          # };
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = true;
          format = "({})";
          format-icons = {
            focused = "";
          };
        };

        "custom/window-close" = {
          format = "{icon}";
          format-icons = " 󰅗 ";
          tooltip = false;
          on-click = "hyprctl dispatch forcekillactive";
        };
        "custom/window-full" = {
          format = "{icon}";
          format-icons = " 󰦓 ";
          tooltip = false;
          on-click = "hyprctl dispatch fullscreen 1";
        };

        "hyprland/window" = {
          format = "{}";
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰛐";
            deactivated = "󰛑";
          };
          tooltip = false;
          timeout = 760.0;
        };

        "custom/tray" = {
          format = "{icon})";
          format-icons = "󰠵";
          on-click = "pkill tray-tui || ghostty --class=pc.tray-tui -e tray-tui";
          # "pkill tray-tui || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class tray-tui -e tray-tui";
          tooltip = false;
        };

        "clock" = {
          # "timezone" = "America/New_York";
          format = " {:%H:%M}";
          tooltip-format = "<small>{:%d/%m/%Y}</small>\n<tt><small>{calendar}</small></tt>";
          format-alt = " {:%d/%m/%Y}";
          tooltip = false;
        };

        "cpu" = {
          format = " {usage}%";
          interval = 5;
          tooltip = false;

          on-click = "pkill btop || ghostty --class=pc.btop -e btop -p 1";
          # "on-click" =
          #   "pkill btop || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class btop -e btop -p 1";
        };
        "memory" = {
          format = " {percentage}%";
          interval = 5;
          tooltip = false;
          on-click = "pkill btop || ghostty --class=pc.btop -e btop";
          # "on-click" =
          #   "pkill btop || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class btop -e btop";

        };

        "backlight" = {
          # "device" = "intel_backlight";
          min = 0;
          max = 100;
          on-click = "pkill hyprsunset || hyprsunset -t 3500";
          on-scroll-up = "brightnessctl s 1%+";
          on-scroll-down = "brightnessctl s 1%-";
          orientation = "horizontal";
          format = "{icon} {percent}%";
          tooltip = false;
          format-icons = [
            "󰛩"
            "󱩎"
            "󱩏"
            "󱩐"
            "󱩑"
            "󱩒"
            "󱩓"
            "󱩔"
            "󱩕"
            "󱩖"
            "󰛨"
          ];

        };
        battery = {
          states = {
            good = 100;
            moderate = 50;
            warning = 30;
            critical = 20;
          };
          format = "{icon}{capacity}%";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format-charging = "{icon}󱐋{capacity}%";
          format-plugged = "󰂄󰚥{capacity}%";
          format-full = "󰂄󰚥{capacity}%";
          format-alt = "{icon}{time}";
          format-time = "{H}:{M}";
          tooltip = false;
          interval = 5;
        };

        "hyprland/language" = {
          format = "({}󰥻";
          format-en = "us";
          format-ru = "ru";
          keyboard-name = "asus-keyboard-2";
          on-click = "hyprctl switchxkblayout asus-keyboard-2 next";

          # "on-click" = "hyprctl switchxkblayout asus-keyboard-2 next";
          # "tooltip" = false;

        };

        "group/group-power" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            children-class = "not-power";
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/power"
            "custom/off"
            "custom/reboot"
            "custom/quit"
            "custom/suspend"
            "custom/lock"
          ];
        };
        "custom/quit" = {
          format = "{icon}";
          format-icons = " 󰈆 ";
          tooltip = false;
          on-click = "sleep 1; hyprctl dispatch exit";
        };
        "custom/lock" = {
          format = "{icon}";
          format-icons = " 󰍁 ";
          tooltip = false;
          on-click = "loginctl lock-session";
        };
        "custom/suspend" = {
          format = "{icon}";
          format-icons = " 󰒲 ";
          tooltip = false;
          on-click = "loginctl lock-session | systemctl suspend";
        };
        "custom/reboot" = {
          format = "{icon}";
          format-icons = " 󰑓 ";
          tooltip = false;
          on-click = "systemctl reboot";
        };
        "custom/off" = {
          format = "|{icon}";
          format-icons = " 󰐥 ";
          tooltip = false;
          on-click = "systemctl poweroff";
        };
        "custom/power" = {
          format = "{icon}";
          format-icons = "[ 󰐼 ]";
          tooltip = false;
        };

        "network" = {
          # "interface" = "wlp2*"; // (Optional) To force the use of this interface
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-wifi = "{icon} {essid}";
          format-ethernet = "󰱔 {essid}";
          format-linked = "{󰤭 ifname}(No IP)";
          format-disconnected = "󰤮 off";
          # "tooltip-format" = "{ifname}via{gwaddr}";
          # "format-disabled" = "󰖪 off";
          # "format-alt" = "{signalStrength}-wifi{frequency}";
          tooltip = false;
          on-click = "pkill impala || ghostty --class=pc.impala -e impala";
          # "on-click" =
          #   "pkill impala || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class impala -e impala";
          interval = 5;
        };

        "bluetooth" = {
          #"format" = "{status}";
          format-on = "󰂯{status}";
          format-disabled = "";
          format-off = "󰂲{status}";
          format-connected = "󰂱{device_alias}";
          format-connected-battery = "󰂱{icon}{device_alias}";
          # "tooltip-format-on" = "{controller_address}{controller_address_type}";
          # "tooltip-format-off" = "{controller_address}{controller_address_type}";
          # "tooltip-format-connected" = "{device_address}{controller_alias}";
          # "tooltip-format-connected-battery" =
          #   "{device_battery_percentage}%{device_address}{controller_alias}";
          format-icons = [
            "󰥇"
            "󰤾"
            "󰤿"
            "󰥀"
            "󰥁"
            "󰥂"
            "󰥃"
            "󰥄"
            "󰥅"
            "󰥆"
            "󰥈"
          ];
          tooltip = false;
          on-click = "pkill bluetui || ghostty --class=pc.bluetui -e bluetui";
          # "on-click" =
          #   "pkill bluetui || wezterm --config hide_tab_bar_if_only_one_tab=true -e --class bluetui -e bluetui";
        };

        # "wireplumber" = {
        #   "format" = "{icon} {volume}%";
        #   "format-muted" = " 󰖁 {volume}% ";
        #   "format-source" = "";
        #   "format-source-muted" = "";
        #   "format-icons" = {
        #     "headphone" = "";
        #     "hands-free" = "";
        #     "headset" = "";
        #     "phone" = "";
        #     "portable" = "";
        #     "car" = "";
        #     "default" = [
        #       ""
        #       ""
        #       ""
        #     ];
        #   };
        #   "on-click" = "pkill ncpamixer || ghostty --class=pc.ncpamixer -e ncpamixer -to";
        #   "tooltip" = false;
        # };

        "pulseaudio#output" = {
          max-volume = 100;
          # "scroll-step" = 1; // %, can be a float
          format = "{icon} {volume}%";
          format-muted = "󰝟 {volume}%";
          format-bluetooth = "󰂯{icon} {volume}%";
          format-bluetooth-muted = "󰂯󰟎 {volume}%";

          format-icons = {
            headphone = "󰋋";
            hands-free = "󰥰";
            headset = "󰥰";
            phone = "󰏳";
            portable = "󰏳";
            car = "󰄋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          tooltip = false;
          on-click = "pkill wiremix || ghostty --class=pc.wiremix -e wiremix -v output";
        };
        "pulseaudio#input" = {
          format = "{format_source}";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          # "scroll-step" = 5;
          tooltip = false;
          on-click = "pkill wiremix || ghostty --class=pc.wiremix -e wiremix -v input";
        };

        #"mpd" = {
        #"max-length" = 25;
        #"format" = "<span foreground='#bb9af7'></span> {title}";
        #"format-paused" = " {title}";
        #"format-stopped" = "<span foreground='#bb9af7'></span>";
        #"format-disconnected" = "";
        #"on-click" = "mpc --quiet toggle";
        #"on-click-right" = "mpc update; mpc ls | mpc add";
        #"on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp ";
        #"on-scroll-up" = "mpc --quiet prev";
        #"on-scroll-down" = "mpc --quiet next";
        #"smooth-scrolling-threshold" = 5;
        #"tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
        #};
      }
    ];
  };
}
