{
  lib,
  config,
  ...
}:

with config.lib.stylix.colors.withHashtag;
let
  fg = base06;
in

lib.mkForce {
  mgr = {
    border_symbol = " ";

  };
}
