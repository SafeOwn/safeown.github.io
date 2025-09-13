{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    languages = {
      # language-server.golangci-lint-lsp = {
      #   command = "golangci-lint-langserver";
      #   config = [
      #     {
      #       command = [
      #         "golangci-lint"
      #         "run"
      #         "--output.json.path"
      #         "stdout"
      #         "--show-stats=false"
      #         "--issues-exit-code=1"
      #       ];
      #     }
      #   ];
      # };
      language = [
        {
          name = "go";
          auto-format = true;
          formatter.command = "golines";
        }
        {
          name = "rust";
          auto-format = true;
          formatter.command = "rustfmt";
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }

        {
          name = "python";
          auto-format = true;
          formatter.command = "yapf";
        }
        {
          name = "lua";
          auto-format = true;
          formatter.command = "stylua";
        }
      ];
    };
    settings = {
      theme = "gruvbox_dark_hard";
      editor = {
        auto-completion = true;
        auto-format = true;
        completion-replace = true;
        line-number = "absolute";
        mouse = false;
        auto-save = true;
        true-color = true;
        color-modes = true;
        undercurl = false;
        popup-border = "all";
        bufferline = "multiple";
        cursorline = true;
        end-of-line-diagnostics = "hint";
        gutters = [
          "diagnostics"
          "spacer"
          "line-numbers"
          "spacer"
          "diff"
        ];
        cursor-shape = {
          insert = "block";
          normal = "block";
          select = "block";
        };
        inline-diagnostics = {
          # cursor-line = "hint";
          cursor-line = "warning";
          # other-lines = "warning";
        };
        lsp = {
          enable = true;
          display-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
        };

        indent-guides = {
          render = true;
          character = "┊";
        };
        whitespace.characters = {
          newline = "↴";
          tab = "⇥";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
          ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };

      keys.normal.";" = {
        y = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE open         > /dev/null";
        v = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE vsplit       > /dev/null";
        h = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE hsplit       > /dev/null";
        Y = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE open    zoom > /dev/null";
        V = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE vsplit  zoom > /dev/null";
        H = ":sh wezterm cli split-pane --left --percent 30 -- /etc/nixos/home/helix/wezilix.sh $WEZTERM_PANE hsplit  zoom > /dev/null";

      };
    };
  };
}
