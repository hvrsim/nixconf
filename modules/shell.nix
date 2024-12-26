{ pkgs, ... }:

{
  users.defaultUserShell = pkgs.fish;

  environment = {
    shells = with pkgs; [
      fish
    ];

    systemPackages = with pkgs; [
      microfetch
      neofetch
      curl
      git
      file
      tree
    ];
  };

  programs = {
    fish.enable = true;

    direnv = {
      enable = true;
      silent = true;
    };
  };
}
