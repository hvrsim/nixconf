{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    tree

    jq
    yq-go

    unzip
    zip

    htop
    pciutils
    usbutils

    wget
    dnsutils
  ];
}
