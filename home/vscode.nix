{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.cursor;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "nixpkgs" = {
              "expr" = "import <nixpkgs> { }";
            };
            "formatting" = {
              "command" = [
                "nix"
                "fmt"
              ];
            };
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/yusuf/Code/nixconf\").nixosConfigurations.thinkpad.options";
              };
            };
          };
        };
      };

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
      ];
    };
  };
}
