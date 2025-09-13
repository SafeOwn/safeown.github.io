{
  services.polybar = {
  enable = true;
#  font-0 = {
    
# "JetBrainsMono Nerd Font Mono:size=11:weight=bold";
#  };
     script = "polybar bar &"; 
  config = {
     "bar/top" = {
   # monitor = "\${env:MONITOR:eDP-1}";
    width = "100%";
    height = "5%";
    radius = 0;
    modules-center = "date";
  };

  "module/date" = {
    type = "internal/date";
    internal = 5;
    date = "%d.%m.%y";
    time = "%H:%M";
    label = "%time%  %date%";
  };
 # extraConfig = ''
 #      [module/date]
 # type = internal/date
 # interval = 5
 # date = "%d.%m.%y"
 # time = %H:%M
 # format-prefix-foreground = \''${colors.foreground-alt}
 # label = %time%  %date%
 # '';
  };
  
};
}
