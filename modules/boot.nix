{
  config,
  lib,
  pkgs,
  ...
}:

let
  omarchyThemes = [
    "default"
    "catppuccin"
    "catppuccin-latte"
    "ethereal"
    "everforest"
    "flexoki-light"
    "gruvbox"
    "hackerman"
    "kanagawa"
    "last-horizon"
    "lumon"
    "lupine"
    "matte-black"
    "miasma"
    "nord"
    "osaka-jade"
    "retro-82"
    "ristretto"
    "rose-pine"
    "solitude"
    "tokyo-night"
    "vantablack"
    "white"
  ];

  omarchyPlymouth = pkgs.callPackage ../packages/omarchy-plymouth.nix {
    variant = config.boot.plymouth.omarchyTheme;
  };
in
{
  options.boot.plymouth.omarchyTheme = lib.mkOption {
    type = lib.types.enum omarchyThemes;
    default = "default";
    example = "catppuccin";
    description = "Omarchy color and unlock-logo variant used by Plymouth.";
  };

  config = {
    boot = {
      loader.timeout = 0;

      # Plymouth handles both the splash animation and systemd's LUKS prompt.
      plymouth = {
        enable = true;
        theme = "omarchy";
        themePackages = [ omarchyPlymouth ];
      };

      consoleLogLevel = 3;
      initrd = {
        kernelModules = [ "amdgpu" ];
        verbose = false;
      };
      kernelParams = [ "quiet" ];
    };

    # The LUKS passphrase is the authentication boundary for this single-user
    # machine. Only tty1 is logged in automatically, and only once per boot.
    services.getty = {
      autologinUser = "yusuf";
      autologinOnce = true;
    };
  };
}
