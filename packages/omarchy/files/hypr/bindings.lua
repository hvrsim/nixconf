-- A NixOS-native binding set: Omarchy's maintained Lua helpers and visual
-- defaults remain in use, while every external command below is declaratively
-- installed by the profile.

local function launch(command)
  return "uwsm-app -- " .. command
end

-- Applications and menus.
o.bind("SUPER + RETURN", "Terminal", launch("foot"))
o.bind("SUPER + SHIFT + RETURN", "Browser", launch("firefox"))
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", launch("firefox --private-window"))
o.bind("SUPER + SHIFT + F", "File manager", launch("nautilus --new-window"))
o.bind("SUPER + SHIFT + N", "Editor", launch("foot -e nvim"))
o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle")
o.bind("SUPER + ALT + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ESCAPE", "System menu", "omarchy-menu toggle system", { locked = true })
o.bind("XF86PowerOff", "System menu", "omarchy-menu toggle system", { locked = true })

-- Window and workspace navigation.
o.bind("SUPER + W", "Close window", hl.dsp.window.close())
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + J", "Toggle split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + P", "Pseudo window", hl.dsp.window.pseudo())
o.bind("SUPER + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + ALT + F", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized" }))

for _, direction in ipairs({
  { key = "LEFT", value = "l" },
  { key = "RIGHT", value = "r" },
  { key = "UP", value = "u" },
  { key = "DOWN", value = "d" },
}) do
  o.bind("SUPER + " .. direction.key, "Focus " .. direction.value, hl.dsp.focus({ direction = direction.value }))
  o.bind("SUPER + SHIFT + " .. direction.key, "Swap " .. direction.value, hl.dsp.window.swap({ direction = direction.value }))
end

local workspace_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
for index, key in ipairs(workspace_keys) do
  local workspace = index == 10 and 10 or index
  o.bind("SUPER + " .. key, "Workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + ALT + " .. key, "Move silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

o.bind("SUPER + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + ALT + S", "Move to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("ALT + TAB", "Next window", hl.dsp.window.cycle_next())
o.bind("ALT + SHIFT + TAB", "Previous window", hl.dsp.window.cycle_next({ next = false }))

o.bind("SUPER + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })
o.bind("SUPER + G", "Toggle group", hl.dsp.group.toggle())
o.bind("SUPER + ALT + TAB", "Next grouped window", hl.dsp.group.next())
o.bind("SUPER + ALT + SHIFT + TAB", "Previous grouped window", hl.dsp.group.prev())

-- Omarchy shell surfaces retained by this port.
o.bind("SUPER + CTRL + SPACE", "Background picker", "omarchy-menu toggle background")
o.bind("SUPER + CTRL + V", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")
o.bind("SUPER + CTRL + E", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")
o.bind("SUPER + CTRL + A", "Audio", "omarchy-shell shell toggle omarchy.audio")
o.bind("SUPER + CTRL + B", "Bluetooth", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("SUPER + CTRL + ALT + D", "Calendar", "omarchy-shell shell toggle omarchy.clock")
o.bind("SUPER + CTRL + W", "Network", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + CTRL + P", "Power", "omarchy-shell shell toggle omarchy.power")
o.bind("SUPER + comma", "Dismiss notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
o.bind("SUPER + SHIFT + ALT + comma", "Notification history", "omarchy-shell notifications showHistory")

-- Capture, activity, and session controls.
o.bind("PRINT", "Capture region", "omarchy-screenshot area")
o.bind("SHIFT + PRINT", "Capture display", "omarchy-screenshot output")
o.bind("ALT + PRINT", "Toggle screen recording", "omarchy-screenrecord")
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + T", "Activity monitor", launch("foot -e btop"))
o.bind("SUPER + CTRL + L", "Lock", "omarchy-system-lock", { locked = true })
o.bind("SUPER + SHIFT + E", "Exit Hyprland", "uwsm stop")

-- Hardware media keys use SwayOSD for consistent feedback.
o.bind("XF86AudioRaiseVolume", "Volume up", "swayosd-client --output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "swayosd-client --output-volume lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "swayosd-client --output-volume mute-toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "swayosd-client --input-volume mute-toggle", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "swayosd-client --brightness raise", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "swayosd-client --brightness lower", { locked = true, repeating = true })
o.bind("XF86AudioNext", "Next track", "playerctl next", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "playerctl previous", { locked = true })
o.bind("XF86AudioPlay", "Play or pause", "playerctl play-pause", { locked = true })
o.bind("XF86AudioPause", "Play or pause", "playerctl play-pause", { locked = true })
