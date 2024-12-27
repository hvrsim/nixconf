{ pkgs, ... }:

{
  programs.bat.enable = true;
  programs.ripgrep.enable = true;

  home.packages = [
    pkgs.microfetch
    pkgs.nixd
    pkgs.rustup
  ];

  programs.git = {
    enable = true;
    userName = "Yusuf M";
    userEmail = "circutrider21@gmail.com";
  };
}
