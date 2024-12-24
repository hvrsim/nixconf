{pkgs, ...}: {
  imports = [
    ../../home/core.nix
  ];

  programs.git = {
    enable = true;
    userName = "Yusuf M";
    userEmail = "circutrider21@outlook.com";
  };
}
