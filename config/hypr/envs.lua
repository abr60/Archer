-- Personal environment variable overrides.
-- These run after Archer defaults and take precedence.

-- --- Graphics & Rendering ---
hl.env("CURSOR_FLAGS", "1")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- --- Cursor Theming ---
-- Matches Hyprcursor (modern) and XCursor (legacy fallback).
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

-- --- Toolkit & App Styling ---
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- Use qt6ct or qt5ct for styling
-- hl.env("GTK_THEME", "Adwaita:dark")   -- Use dark Adwaita theme for GTK apps
