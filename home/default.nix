{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    users.yusuf = {
      imports = [
        ./shell.nix
        ./git.nix
        ./packages.nix
      ];

      home.stateVersion = "26.05";
      programs.home-manager.enable = true;
    };
  };
}
