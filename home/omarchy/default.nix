{
  omarchyPackage,
  ...
}:

{
  _module.args = {
    inherit omarchyPackage;
    omarchyPath = "${omarchyPackage}/share/omarchy";
  };

  imports = [
    ./applications.nix
    ./hyprland.nix
    ./services.nix
  ];
}
