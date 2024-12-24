{pkgs, nixvim, ...}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    ../../home/core.nix
  ];

  programs = {
    git = {
      enable = true;
      userName = "Yusuf M";
      userEmail = "circutrider21@outlook.com";
    };

    nixvim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };
  };
}
