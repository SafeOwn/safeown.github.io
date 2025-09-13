{
  programs.yazi.keymap = {
    input.prepend_keymap = [
      {
        on = "escape";
        run = "close";
        desc = "Cancel input";
      }

    ];
    mgr.prepend_keymap = [
      {
        on = [
          "e"
          "s"
        ];
        run = "plugin what-size";
        desc = "Calc size of selection or cwd";
      }
      {
        on = "Z";
        run = "plugin fzf";
        desc = "Jump to a file/directory via fzf";
      }
      {
        on = "z";
        run = "plugin zoxide";
        desc = "Jump to a directory via zoxide";
      }
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore the preview pane";
      }
      {
        on = "f";
        run = "plugin jump-to-char";
        desc = "Jump to char";
      }
      {
        on = "F";
        run = "plugin smart-filter";
        desc = "Smart filter";
      }
      # {
      #   on = "M";
      #   run = "plugin mount";
      # }
      {
        on = [
          "c"
          "m"
        ];
        run = "plugin chmod";
        desc = "Chmod on selected files";
      }
      {
        on = [
          "g"
          "r"
        ];
        run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
        desc = "back to the root of repository";
      }
      {
        on = [
          "e"
          "t"
        ];
        run = "plugin hide-preview";
        desc = "Hide or show preview";
      }
      {
        on = [
          "e"
          "d"
        ];
        run = ''shell 'dragon-drop -T "$@"' --confirm'';
        desc = "Drag & Drop file";
      }
      # gvfs plugin
      {
        on = [
          "M"
          "m"
        ];
        run = "plugin gvfs -- select-then-mount";
        desc = "Select device then mount";
      }
      # or this if you want to jump to mountpoint after mounted
      {
        on = [
          "M"
          "m"
        ];
        run = "plugin gvfs -- select-then-mount --jump";
        desc = "Select device to mount and jump to its mount point";
      }
      # This will remount device under cwd (e.g. cwd = /run/user/1000/gvfs/DEVICE_1/FOLDER_A, device mountpoint = /run/user/1000/gvfs/DEVICE_1)
      {
        on = [
          "M"
          "R"
        ];
        run = "plugin gvfs -- remount-current-cwd-device";
        desc = "Remount device under cwd";
      }
      {
        on = [
          "M"
          "u"
        ];
        run = "plugin gvfs -- select-then-unmount";
        desc = "Select device then unmount";
      }
      # or this if you want to unmount and eject device. Ejected device can safely be removed.
      # Fallback to normal unmount if not supported by device.
      {
        on = [
          "M"
          "u"
        ];
        run = "plugin gvfs -- select-then-unmount --eject";
        desc = "Select device then eject";
      }

      # Add|Edit|Remove mountpoint: smb, sftp, ftp, nfs, google-drive, dns-sd, dav, davs, dav+sd, davs+sd, afp, afc, sshfs
      # Read more about the schemes here: https://wiki.gnome.org/Projects(2f)gvfs(2f)schemes.html
      # For example: smb://user:password@192.168.1.2/share, sftp://user@192.168.1.2/, ftp://192.168.1.2/
      {
        on = [
          "M"
          "a"
        ];
        run = "plugin gvfs -- add-mount";
        desc = "Add a GVFS mount URI";
      }
      # Edit or remove a GVFS mount URI will clear saved passwords for that mount URI.
      {
        on = [
          "M"
          "e"
        ];
        run = "plugin gvfs -- edit-mount";
        desc = "Edit a GVFS mount URI";
      }
      {
        on = [
          "M"
          "r"
        ];
        run = "plugin gvfs -- remove-mount";
        desc = "Remove a GVFS mount URI";
      }

      # Jump
      {
        on = [
          "g"
          "m"
        ];
        run = "plugin gvfs -- jump-to-device";
        desc = "Select device then jump to its mount point";
      }
      {
        on = [
          "`"
          "`"
        ];
        run = "plugin gvfs -- jump-back-prev-cwd";
        desc = "Jump back to the position before jumped to device";
      }

    ];
  };
}
