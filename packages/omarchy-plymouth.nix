{
  fetchFromGitHub,
  imagemagick,
  lib,
  stdenvNoCC,
  variant ? "default",
}:

assert lib.assertMsg (
  builtins.match "[a-z0-9-]+" variant != null
) "invalid Omarchy Plymouth variant";

stdenvNoCC.mkDerivation {
  pname = "omarchy-plymouth";
  version = "unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "basecamp";
    repo = "omarchy";
    rev = "83881e979b35468c3e7d60b171e319ede61a88fd";
    hash = "sha256-y//QxpybG3Wl+b4G26qebEU3E8kfUUEdnUWiU+bteCw=";
  };

  dontBuild = true;
  nativeBuildInputs = lib.optional (variant != "default") imagemagick;

  installPhase = ''
    runHook preInstall

    themeDir="$out/share/plymouth/themes/omarchy"
    mkdir -p "$themeDir"
    install -m644 \
      default/plymouth/bullet.png \
      default/plymouth/entry.png \
      default/plymouth/lock.png \
      default/plymouth/logo.png \
      default/plymouth/omarchy.plymouth \
      default/plymouth/omarchy.script \
      default/plymouth/progress_bar.png \
      default/plymouth/progress_box.png \
      -t "$themeDir"

    if [[ ${lib.escapeShellArg variant} != default ]]; then
      variantDir=${lib.escapeShellArg "themes/${variant}"}
      colors="$variantDir/colors.toml"

      cp "$variantDir/unlock.png" "$themeDir/logo.png"

      themeColor() {
        local key="$1"
        awk -F= -v key="$key" '
          $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
            value = $2
            gsub(/^[[:space:]\"]+|[[:space:]\"]+$/, "", value)
            print value
            exit
          }
        ' "$colors"
      }

      background=$(themeColor background)
      foreground=$(themeColor foreground)
      test -n "$background" -a -n "$foreground"

      backgroundHex="''${background#\#}"
      backgroundRed=$(awk -v n=$((16#''${backgroundHex:0:2})) 'BEGIN { printf "%.3f", n / 255 }')
      backgroundGreen=$(awk -v n=$((16#''${backgroundHex:2:2})) 'BEGIN { printf "%.3f", n / 255 }')
      backgroundBlue=$(awk -v n=$((16#''${backgroundHex:4:2})) 'BEGIN { printf "%.3f", n / 255 }')

      substituteInPlace "$themeDir/omarchy.script" \
        --replace-fail \
          "Window.SetBackgroundTopColor(0.101, 0.105, 0.149);" \
          "Window.SetBackgroundTopColor($backgroundRed, $backgroundGreen, $backgroundBlue);" \
        --replace-fail \
          "Window.SetBackgroundBottomColor(0.101, 0.105, 0.149);" \
          "Window.SetBackgroundBottomColor($backgroundRed, $backgroundGreen, $backgroundBlue);"

      for asset in bullet.png entry.png lock.png progress_bar.png; do
        magick "$themeDir/$asset" \
          -channel RGB +level-colors "$foreground","$foreground" \
          "$themeDir/$asset"
      done
    fi

    substituteInPlace "$themeDir/omarchy.plymouth" \
      --replace-fail "/usr/share/plymouth/themes/omarchy" "$themeDir"

    runHook postInstall
  '';

  meta = {
    description = "Omarchy ${variant} Plymouth boot and disk-unlock theme";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
