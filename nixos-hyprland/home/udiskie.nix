{
  services.udiskie = {
    enable = true;
    automount = false;
    tray = "auto";
    settings = {
      programm_options = {
        udiskie_version = 2;
      };
    };
  };
}
