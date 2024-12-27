{ nixconf, pkgs, ... }:

{
  users.defaultUserShell = pkgs.fish;

  environment = {
    shells = with pkgs; [
      fish
    ];

    systemPackages = with pkgs; [
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

  nix.nixPath = [ "nixpkgs=${nixconf.inputs.nixpkgs}" ];
}
