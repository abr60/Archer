#!/usr/bin/env python3
"""
Event-driven MPRIS controller for Waybar — Icon Only Mode.
Zero polling, instant updates via DBus signals.
"""

import sys
import json
import os
from pathlib import Path

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

# ----------------------------------------------------------------------
#  Configuration & Fallbacks
# ----------------------------------------------------------------------
# Priority ordering for concurrent media streams
PRIORITY = [
    "mpd", "spotify", "youtube-music", "youtube", "clapper", 
    "cmus", "ncspot", "vlc", "mpv", "chromium", "firefox", "default"
]

# Explicit icon overrides. Change these glyphs easily as needed.
ICONS = {
    "mpd": "󰎆",
    "spotify": "",
    "youtube": "",
    "youtube-music": "󰎆",
    "clapper": "🎬",        # Gtk4 Streaming Video Player
    "cmus": "󰓃",           # CLI Player
    "ncspot": "",         # CLI Spotify client
    "mpv": "",
    "vlc": "󰕼",
    "chromium": "",
    "firefox": "",
    "default": "󰎆",        # Radio wrappers / Fallbacks
}

STATE_DIR = Path.home() / ".local" / "state" / "Archer"
STATE_FILE = STATE_DIR / "mpris-last-player"

# ----------------------------------------------------------------------
#  Deep Content & App Identifier Helper
# ----------------------------------------------------------------------
def resolve_identity(bus_name: str, metadata: dict) -> str:
    """
    Parses DBus signatures and complex metadata objects to route instances 
    efficiently even when tracking properties fail to populate early.
    """
    raw_name = bus_name.split(".")[-1].lower()
    full_name = bus_name.lower()  # e.g. org.mpris.mediaplayer2.chromium.instance582132

    # Extract data securely converting types
    url = str(metadata.get("xesam:url", "")).lower()
    title = str(metadata.get("xesam:title", "")).lower()
    album = str(metadata.get("xesam:album", "")).lower()
    track_id = str(metadata.get("mpris:trackid", "")).lower()

    # Route broad browser engines to explicit platforms
    if any(x in full_name for x in ["chromium", "firefox", "brave", "chrome"]):
        # YouTube Music Specific Profiles
        if "youtube.com/music" in url or "music.youtube" in url or "youtube music" in album or "youtubemusic" in track_id:
            return "youtube-music"
        # Standard YouTube Stream Handlers
        if "youtube.com" in url or "youtube" in title or "youtube" in track_id:
            return "youtube"
        # Streaming Radio / App Profiles
        if "radio" in title or "radio" in url or "stream" in url:
            return "default"
        # Fallback: browser is playing something — treat as youtube (most common case)
        if title:
            return "youtube"
        
    # Match generic variations
    if "clapper" in raw_name:
        return "clapper"
    if "cmus" in raw_name:
        return "cmus"
    if "ncspot" in raw_name:
        return "ncspot"
    if "vlc" in raw_name:
        return "vlc"
    if "mpv" in raw_name:
        return "mpv"
    if "spotify" in raw_name:
        return "spotify"
    if "mpd" in raw_name:
        return "mpd"
        
    return raw_name

# ----------------------------------------------------------------------
#  Formatting Helpers
# ----------------------------------------------------------------------
def escape_pango(text: str) -> str:
    if not text:
        return ""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def get_icon(identity: str) -> str:
    return ICONS.get(identity, ICONS["default"])

# ----------------------------------------------------------------------
#  MPRIS Controller Core
# ----------------------------------------------------------------------
class MprisController:
    def __init__(self):
        self.players = {}
        self.active_player = None
        self.last_emitted = None
        self.initial_scan_done = False
        
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SessionBus()
        
        self.bus.add_signal_receiver(
            self._on_name_owner_changed,
            signal_name="NameOwnerChanged",
            dbus_interface="org.freedesktop.DBus",
        )
        
        self._scan_existing_players()
        self.initial_scan_done = True
        
        self.mainloop = GLib.MainLoop()
        try:
            self.mainloop.run()
        except KeyboardInterrupt:
            sys.exit(0)

    def _scan_existing_players(self):
        for name in self.bus.list_names():
            if name.startswith("org.mpris.MediaPlayer2."):
                self._add_player(name)
        if not self.active_player:
            self._emit_empty()
    
    def _add_player(self, bus_name: str) -> None:
        if bus_name in self.players:
            return
        
        try:
            proxy = self.bus.get_object(bus_name, "/org/mpris/MediaPlayer2")
            iface = dbus.Interface(proxy, dbus_interface="org.freedesktop.DBus.Properties")
        except dbus.exceptions.DBusException:
            return
        
        try:
            status = str(iface.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus"))
        except dbus.exceptions.DBusException:
            status = "Stopped"
        
        try:
            metadata = dict(iface.Get("org.mpris.MediaPlayer2.Player", "Metadata"))
        except dbus.exceptions.DBusException:
            metadata = {}
        
        self.players[bus_name] = {
            "proxy": proxy,
            "status": status,
            "metadata": metadata,
        }
        
        iface.connect_to_signal(
            "PropertiesChanged",
            lambda iface_name, changed, invalidated, sender=bus_name: 
                self._on_properties_changed(sender, changed),
            dbus_interface="org.freedesktop.DBus.Properties",
        )
        
        if self.initial_scan_done:
            self._reevaluate_active_player()
    
    def _remove_player(self, bus_name: str) -> None:
        self.players.pop(bus_name, None)
        self._reevaluate_active_player()
    
    def _reevaluate_active_player(self):
        """Pick active media stream evaluating resolved identities against priorities."""
        # Check for Playing instances
        for priority_target in PRIORITY:
            for bname, data in self.players.items():
                resolved = resolve_identity(bname, data["metadata"])
                if resolved == priority_target and data["status"] == "Playing":
                    self.active_player = bname
                    self._emit_state()
                    return

        # Check for Paused instances
        for priority_target in PRIORITY:
            for bname, data in self.players.items():
                resolved = resolve_identity(bname, data["metadata"])
                if resolved == priority_target and data["status"] == "Paused":
                    self.active_player = bname
                    self._emit_state()
                    return
        
        self.active_player = None
        self._emit_empty()
    
    def _emit_state(self):
        if not self.active_player:
            return
        
        player = self.players[self.active_player]
        metadata = player["metadata"]
        status = player["status"]
        
        identity = resolve_identity(self.active_player, metadata)
        
        title = str(metadata.get("xesam:title", ""))
        artist = ""
        if metadata.get("xesam:artist"):
            artist = str(metadata["xesam:artist"][0]) if isinstance(metadata["xesam:artist"], list) else str(metadata["xesam:artist"])
        album = str(metadata.get("xesam:album", ""))
        
        icon = get_icon(identity)
        # Icon Only Formatting - Pango Markup wrapped around the glyph
        display = f"<span size='large'>{icon}</span>"
        
        status_class = status.lower() if status.lower() in ("playing", "paused", "stopped") else "stopped"
        
        try:
            STATE_FILE.write_text(identity)
        except:
            pass
        
        output = {
            "text": display,
            "class": status_class,
            "tooltip": f"App Target: {identity}\nArtist: {artist}\nTitle: {title}\nAlbum: {escape_pango(album)}\nStatus: {status}"
        }
        
        output_str = json.dumps(output, ensure_ascii=False)
        if output_str != self.last_emitted:
            print(output_str, flush=True)
            self.last_emitted = output_str
    
    def _emit_empty(self):
        output = {"text": "", "class": "none"}
        output_str = json.dumps(output, ensure_ascii=False)
        if output_str != self.last_emitted:
            print(output_str, flush=True)
            self.last_emitted = output_str

    def _on_name_owner_changed(self, name, old_owner, new_owner):
        if not name.startswith("org.mpris.MediaPlayer2."):
            return
        if new_owner:
            self._add_player(name)
        else:
            self._remove_player(name)
    
    def _on_properties_changed(self, sender, changed):
        if sender not in self.players:
            return
        
        player = self.players[sender]
        if "PlaybackStatus" in changed:
            player["status"] = str(changed["PlaybackStatus"])
        if "Metadata" in changed:
            player["metadata"] = dict(changed["Metadata"])
        
        self._reevaluate_active_player()

if __name__ == "__main__":
    MprisController()