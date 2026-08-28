{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";

      os-rebuild = "sudo nixos-rebuild switch --flake ~/nixconf#inspiron";
      os-update = "nix flake update --flake ~/nixconf";
    };

    interactiveShellInit = ''
      set fish_greeting
    '';
  };

  # programs.starship = {
  #   enable = true;
  #   enableFishIntegration = true;
  # };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat.enable = true;
}
