{
  bash,
  bluez,
  brightnessctl,
  coreutils,
  curl,
  fetchFromGitHub,
  findutils,
  foot,
  gawk,
  grim,
  gnugrep,
  gnused,
  hyprland,
  imagemagick,
  iproute2,
  iputils,
  iw,
  jq,
  lib,
  libnotify,
  makeWrapper,
  networkmanager,
  perl,
  pipewire,
  power-profiles-daemon,
  procps,
  qrencode,
  quickshell,
  slurp,
  stdenvNoCC,
  systemd,
  theme ? "nord",
  upower,
  uwsm,
  util-linux,
  vips,
  wallpaper ? null,
  wf-recorder,
  wl-clipboard,
  writeShellApplication,
  writeShellScript,
  wtype,
  xdg-utils,
}:

let
  themes = import ../../lib/omarchy-themes.nix;
  runtimeStateHome = "\${XDG_STATE_HOME:-$HOME/.local/state}";
  files = ./files;
  screenshot = writeShellApplication {
    name = "omarchy-screenshot";
    runtimeInputs = [
      coreutils
      grim
      hyprland
      jq
      libnotify
      slurp
      wl-clipboard
    ];
    text = ''
      mode="''${1:-area}"
      screenshots_dir="''${XDG_SCREENSHOTS_DIR:-''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}"
      mkdir -p "$screenshots_dir"
      output="$screenshots_dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

      case "$mode" in
        area)
          geometry=$(slurp) || exit 0
          grim -g "$geometry" "$output"
          ;;
        window)
          geometry=$(hyprctl -j activewindow | jq -er '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          grim -g "$geometry" "$output"
          ;;
        output) grim "$output" ;;
        *) echo "Usage: omarchy-screenshot [area|window|output]" >&2; exit 2 ;;
      esac

      wl-copy --type image/png < "$output"
      notify-send --app-name=Omarchy --icon="$output" "Screenshot copied" "$output"
    '';
  };
  screenrecord = writeShellApplication {
    name = "omarchy-screenrecord";
    runtimeInputs = [
      coreutils
      libnotify
      slurp
      systemd
      wf-recorder
    ];
    text = ''
      unit=omarchy-screenrecord.service
      if systemctl --user is-active --quiet "$unit"; then
        systemctl --user kill --signal=INT "$unit"
        notify-send --app-name=Omarchy "Screen recording saved"
        exit 0
      fi

      geometry=$(slurp) || exit 0
      recordings_dir="''${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
      mkdir -p "$recordings_dir"
      output="$recordings_dir/$(date +'%Y-%m-%d_%H-%M-%S').mp4"
      systemd-run --user --collect --unit=omarchy-screenrecord \
        ${wf-recorder}/bin/wf-recorder --geometry "$geometry" --audio --file "$output"
      notify-send --app-name=Omarchy "Screen recording started" "$output"
    '';
  };
  wallpaperPick = writeShellScript "omarchy-wallpaper-pick" ''
    set -euo pipefail

    background=$(omarchy-theme-bg-switcher)
    if [[ -n $background ]]; then
      omarchy-theme-bg-set "$background"
    fi
  '';
in
assert lib.assertOneOf "theme" theme themes;
stdenvNoCC.mkDerivation {
  pname = "omarchy";
  version = "unstable-2026-08-27-${theme}";

  src = fetchFromGitHub {
    owner = "basecamp";
    repo = "omarchy";
    rev = "83881e979b35468c3e7d60b171e319ede61a88fd";
    hash = "sha256-y//QxpybG3Wl+b4G26qebEU3E8kfUUEdnUWiU+bteCw=";
  };

  nativeBuildInputs = [
    bash
    coreutils
    gawk
    findutils
    gnugrep
    gnused
    imagemagick
    makeWrapper
  ];

  dontBuild = true;

  postPatch = ''
    patchShebangs bin/omarchy-theme-color bin/omarchy-theme-set-templates
  '';

  installPhase = ''
    runHook preInstall

    omarchyDir="$out/share/omarchy"
    mkdir -p "$omarchyDir/default" "$omarchyDir/config" "$out/bin"

    cp -r default/hypr "$omarchyDir/default/hypr"
    cp -r default/omarchy "$omarchyDir/default/omarchy"
    cp -r config/hypr "$omarchyDir/config/hypr"
    cp -r config/foot "$omarchyDir/config/foot"
    cp -r config/omarchy "$omarchyDir/config/omarchy"
    cp -r shell "$omarchyDir/shell"
    patchShebangs "$omarchyDir/shell"

    # Keep Omarchy's native menu renderer and application provider, but replace
    # its mutable Arch/provisioning actions with a declarative Nix menu model.
    install -m644 ${files}/omarchy/menu.jsonc \
      "$omarchyDir/default/omarchy/omarchy-menu.jsonc"
    mkdir -p "$omarchyDir/config/nix/hypr"
    install -m644 ${files}/hypr/autostart.lua \
      "$omarchyDir/config/nix/hypr/autostart.lua"
    install -m644 ${files}/hypr/bindings.lua \
      "$omarchyDir/config/nix/hypr/bindings.lua"
    install -m644 ${files}/hypr/input.lua \
      "$omarchyDir/config/nix/hypr/input.lua"
    install -m644 ${files}/omarchy/shell.json \
      "$omarchyDir/config/nix/shell.json"
    # Desktop entries remain launchable, but Delete must not invoke upstream's
    # mutable package-removal flow. Packages are removed from the Nix config.
    substituteInPlace "$omarchyDir/shell/plugins/menu/Menu.qml" \
      --replace-fail \
        'if (event.key === Qt.Key_Delete) {' \
        'if (false && event.key === Qt.Key_Delete) {'

    # Generate the selected theme with Omarchy's own templates during the Nix
    # build. Runtime state therefore only points at immutable store content.
    export HOME="$TMPDIR/home"
    export OMARCHY_PATH="$PWD"
    nextTheme="$HOME/.local/state/omarchy/current/next-theme"
    mkdir -p "$nextTheme"
    cp -r "themes/${theme}/." "$nextTheme/"
    export PATH="$PWD/bin:$PATH"
    bin/omarchy-theme-set-templates
    cp -r "$nextTheme" "$omarchyDir/current-theme"

    ${
      if wallpaper == null then
        ''
          background=$(find "$omarchyDir/current-theme/backgrounds" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \
               -o -iname '*.bmp' -o -iname '*.webp' \) | sort | head -n1)
        ''
      else
        ''
          wallpaperName=${lib.escapeShellArg wallpaper}
          background="$omarchyDir/current-theme/backgrounds/$wallpaperName"
          if [ ! -f "$background" ]; then
            echo "Wallpaper $wallpaperName does not exist in the ${theme} theme" >&2
            exit 1
          fi
        ''
    }
    if [ -n "$background" ]; then
      ln -s "current-theme/backgrounds/$(basename "$background")" \
        "$omarchyDir/current-background"
    fi

    # Plymouth consumes the same package and selected theme as the desktop.
    plymouthDir="$out/share/plymouth/themes/omarchy"
    mkdir -p "$plymouthDir"
    install -m644 \
      default/plymouth/bullet.png \
      default/plymouth/entry.png \
      default/plymouth/lock.png \
      default/plymouth/logo.png \
      default/plymouth/omarchy.plymouth \
      default/plymouth/omarchy.script \
      default/plymouth/progress_bar.png \
      default/plymouth/progress_box.png \
      -t "$plymouthDir"

    cp "themes/${theme}/unlock.png" "$plymouthDir/logo.png"
    colors="themes/${theme}/colors.toml"
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

    backgroundColor=$(themeColor background)
    foregroundColor=$(themeColor foreground)
    test -n "$backgroundColor" -a -n "$foregroundColor"
    backgroundHex="''${backgroundColor#\#}"
    backgroundRed=$(awk -v n=$((16#''${backgroundHex:0:2})) 'BEGIN { printf "%.3f", n / 255 }')
    backgroundGreen=$(awk -v n=$((16#''${backgroundHex:2:2})) 'BEGIN { printf "%.3f", n / 255 }')
    backgroundBlue=$(awk -v n=$((16#''${backgroundHex:4:2})) 'BEGIN { printf "%.3f", n / 255 }')

    substituteInPlace "$plymouthDir/omarchy.script" \
      --replace-fail \
        "Window.SetBackgroundTopColor(0.101, 0.105, 0.149);" \
        "Window.SetBackgroundTopColor($backgroundRed, $backgroundGreen, $backgroundBlue);" \
      --replace-fail \
        "Window.SetBackgroundBottomColor(0.101, 0.105, 0.149);" \
        "Window.SetBackgroundBottomColor($backgroundRed, $backgroundGreen, $backgroundBlue);"

    for asset in bullet.png entry.png lock.png progress_bar.png; do
      magick "$plymouthDir/$asset" \
        -channel RGB +level-colors "$foregroundColor","$foregroundColor" \
        "$plymouthDir/$asset"
    done
    substituteInPlace "$plymouthDir/omarchy.plymouth" \
      --replace-fail "/usr/share/plymouth/themes/omarchy" "$plymouthDir"

    # Runtime adapters for the enabled shell widgets and overlays.
    for command in \
      omarchy-audio-input-set-default \
      omarchy-audio-output-set-default \
      omarchy-audio-output-sink \
      omarchy-audio-sink-availability \
      omarchy-battery-status \
      omarchy-bluetooth-power \
      omarchy-bluetooth-device \
      omarchy-cmd-present \
      omarchy-clipboard-open \
      omarchy-clipboard-paste-file \
      omarchy-clipboard-paste-text \
      omarchy-hyprland-focus-app \
      omarchy-menu-emoji-insert \
      omarchy-menu \
      omarchy-network-band \
      omarchy-network-password \
      omarchy-network-qr \
      omarchy-network-speedtest \
      omarchy-network-status \
      omarchy-notification-send \
      omarchy-powerprofiles-list \
      omarchy-powerprofiles-set \
      omarchy-shell \
      omarchy-system-stats
    do
      install -m755 "bin/$command" "$out/bin/$command"
    done
    for command in \
      omarchy-hyprland-session-locked \
      omarchy-system-lock \
      omarchy-system-wake
    do
      install -m755 "bin/$command" "$out/bin/$command"
    done
    install -m755 ${files}/bin/omarchy-brightness-display \
      "$out/bin/omarchy-brightness-display"
    install -m755 ${files}/bin/omarchy-brightness-keyboard \
      "$out/bin/omarchy-brightness-keyboard"
    install -m755 ${files}/bin/omarchy-dns "$out/bin/omarchy-dns"
    install -m755 ${files}/bin/omarchy-launch-floating-terminal-with-presentation \
      "$out/bin/omarchy-launch-floating-terminal-with-presentation"
    for package in ${screenshot} ${screenrecord}; do
      cp -P "$package/bin/"* "$out/bin/"
    done

    # The upstream clipboard opener assumes Omarchy-specific image and app
    # launchers. Freedesktop MIME associations are the Nix-native equivalent.
    substituteInPlace "$out/bin/omarchy-clipboard-open" \
      --replace-fail 'exec tensaku-edit "$path"' 'exec xdg-open "$path"' \
      --replace-fail 'exec omarchy-launch-browser "$url"' 'exec xdg-open "$url"' \
      --replace-fail 'exec omarchy-launch-editor "$open_file"' 'exec xdg-open "$open_file"'
    # The fullscreen wallpaper picker is another first-party shell surface.
    for command in \
      omarchy-menu-images \
      omarchy-theme-bg-current \
      omarchy-theme-bg-next \
      omarchy-theme-bg-set \
      omarchy-theme-bg-switcher
    do
      install -m755 "bin/$command" "$out/bin/$command"
    done
    for command in \
      omarchy-theme-bg-current \
      omarchy-theme-bg-next \
      omarchy-theme-bg-set \
      omarchy-theme-bg-switcher
    do
      substituteInPlace "$out/bin/$command" \
        --replace-fail '$HOME/.local/state' ${lib.escapeShellArg runtimeStateHome}
    done
    install -m755 ${wallpaperPick} "$out/bin/omarchy-wallpaper-pick"

    # Notifications are a separate porting slice. Keep the no-background path
    # self-contained rather than importing that service for one error message.
    substituteInPlace "$out/bin/omarchy-theme-bg-next" \
      --replace-fail \
        'omarchy-notification-send "No background was found for theme" -t 2000' \
        'echo "No background was found for theme" >&2' \
      --replace-fail \
        'CURRENT_BACKGROUND=$(readlink "$CURRENT_BACKGROUND_LINK")' \
        'CURRENT_BACKGROUND=$(readlink -f "$CURRENT_BACKGROUND_LINK")' \
      --replace-fail \
        'if [[ ''${BACKGROUNDS[$i]} == "$CURRENT_BACKGROUND" ]]; then' \
        'if [[ $(realpath "''${BACKGROUNDS[$i]}") == "$CURRENT_BACKGROUND" ]]; then'

    patchShebangs "$out/bin"

    wallpaperRuntimePath=${
      lib.makeBinPath [
        bash
        bluez
        brightnessctl
        coreutils
        curl
        findutils
        foot
        gawk
        gnugrep
        iproute2
        iputils
        iw
        jq
        networkmanager
        perl
        pipewire
        power-profiles-daemon
        procps
        qrencode
        quickshell
        systemd
        upower
        uwsm
        util-linux
        vips
        wl-clipboard
        wtype
        xdg-utils
      ]
    }
    for command in "$out/bin/"*; do
      wrapProgram "$command" --prefix PATH : "$wallpaperRuntimePath"
    done

    ln -s ../../bin "$omarchyDir/bin"
    install -Dm644 default/fonts/omarchy/omarchy.ttf \
      "$out/share/fonts/truetype/omarchy.ttf"

    # Provisioning and Arch package-management commands are intentionally not
    # exposed. Session startup is entirely owned by UWSM and Home Manager.
    install -m644 ${files}/hypr/upstream-autostart.lua \
      "$omarchyDir/default/hypr/autostart.lua"

    runHook postInstall
  '';

  meta = {
    description = "Nix-native Omarchy desktop, commandlets, and Plymouth theme";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
