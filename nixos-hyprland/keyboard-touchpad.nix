{
  services = {
    # acpid = {
    #   enable = true;
    # };
    logind = {
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandlePowerKey = "suspend";
          HandlePowerKeyLongPress = "poweroff";
        };
      };
    };
    libinput.touchpad = {
      #   accelProfile = "flat";
      naturalScrolling = true;
      #   tapping = false;
      #   clickMethod = "none";
    };
  };
}
