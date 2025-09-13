{
  pkgs,
  ...
}:
let
  yaziPluginsRep = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "de53d90cb2740f84ae595f93d0c4c23f8618a9e4";
    sha256 = "ixZKOtLOwLHLeSoEkk07TB3N57DXoVEyImR3qzGUzxQ=";

  };
  gvfsPlugin = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "gvfs.yazi";
    rev = "924b5c23d503809a9dce26140ff7f10e84709852";
    sha256 = "gIVgGjApAZe+lvyhmWXAzh6gAwi8hqGWKKE7FZnsNK0=";
  };
  whatSizePlugin = pkgs.fetchFromGitHub {
    owner = "pirafrank";
    repo = "what-size.yazi";
    rev = "d8966568f2a80394bf1f9a1ace6708ddd4cc8154";
    sha256 = "s2BifzWr/uewDI6Bowy7J+5LrID6I6OFEA5BrlOPNcM=";
  };
in
{
  programs.yazi.plugins = {
    full-border = "${yaziPluginsRep}/full-border.yazi";
    piper = "${yaziPluginsRep}/piper.yazi";
    mount = "${yaziPluginsRep}/mount.yazi";
    toggle-pane = "${yaziPluginsRep}/toggle-pane.yazi";
    jump-to-char = "${yaziPluginsRep}/jump-to-char.yazi";
    chmod = "${yaziPluginsRep}/chmod.yazi";
    smart-filter = "${yaziPluginsRep}/smart-filter.yazi";
    no-status = "${yaziPluginsRep}/no-status.yazi";
    # gvfs = "${yaziPluginsRep}/gvfs.yazi";
    gvfs = "${gvfsPlugin}";
    what-size = "${whatSizePlugin}";
  };

}
