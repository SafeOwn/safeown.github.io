{ pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  # session = "${pkgs.hyprland}/bin/Hyprland";
  session = "Hyprland";
  username = "safe";
in
{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${username}";
      };
      default_session = {
        command = "${tuigreet} --cmd ${session} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot' --theme 'border=blue;text=d5c4a1;prompt=green;time=red;action=d5c4a1;button=yellow;container=black;input=d5c4a1'";
        user = "greeter";
        # user = "${username}";
      };
    };
  };
}
