{ pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.yusuf = {
    isNormalUser = true;
    description = "yusuf";
    uid = 1000;
    shell = pkgs.fish;

    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "kvm"
    ];
  };

  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
  ];
}
