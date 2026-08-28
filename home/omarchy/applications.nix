{
  config,
  omarchyPackage,
  omarchyPath,
  pkgs,
  ...
}:

{
  home = {
    packages = with pkgs; [
      btop
      evince
      firefox
      foot
      gnome-text-editor
      grim
      gtk3
      hyprpicker
      libnotify
      loupe
      nautilus
      neovim
      omarchyPackage
      perl
      playerctl
      quickshell
      qt6.qtimageformats
      satty
      slurp
      swayosd
      wf-recorder
      wl-clipboard
      wtype
      xdg-utils
    ];

    # UWSM starts outside a login shell. Make the per-user profile explicit so
    # every Nix-built launcher and helper is available to Hyprland and QML.
    sessionPath = [ "/etc/profiles/per-user/${config.home.username}/bin" ];
    sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "nvim";
      OMARCHY_PATH = omarchyPath;
      TERMINAL = "foot";
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "Adwaita";
    };
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "text/plain" = [ "org.gnome.TextEditor.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "foot/foot.ini".source = "${omarchyPath}/config/foot/foot.ini";
    "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
