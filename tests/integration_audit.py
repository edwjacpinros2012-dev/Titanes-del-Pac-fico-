#!/usr/bin/env python3
"""Integration audit for account, settings, save, and main game wiring."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
checks = []

def check(ok, message):
    checks.append((bool(ok), message))

project = (ROOT / "project.godot").read_text(encoding="utf-8")
account = (ROOT / "scripts/accounts/account_manager.gd").read_text(encoding="utf-8")
ui = (ROOT / "scripts/accounts/account_ui.gd").read_text(encoding="utf-8")
settings = (ROOT / "scripts/core/settings_manager.gd").read_text(encoding="utf-8")
save = (ROOT / "scripts/core/save_manager.gd").read_text(encoding="utf-8")
main = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
workflow = (ROOT / ".github/workflows/godot-validation.yml").read_text(encoding="utf-8")

for name, path in {
    "AccountManager": "scripts/accounts/account_manager.gd",
    "SettingsManager": "scripts/core/settings_manager.gd",
    "AccountUI": "scripts/accounts/account_ui.gd",
    "SaveSystem": "scripts/core/save_manager.gd",
}.items():
    check(f'{name}="*res://{path}"' in project, f"{name} autoload is registered")
    check((ROOT / path).is_file(), f"{name} autoload file exists")

check("begin_google_sign_in" in ui and "AccountManager.begin_google_sign_in" in ui,
      "Google registration UI calls account flow")
check("no disponible" in account.lower() and "oauth" in account.lower(),
      "Google auth stub clearly reports OAuth is not configured")
check("begin_offline_session" in ui and "AccountManager.begin_offline_session" in ui,
      "offline play UI calls account flow")
check("set_display_name" in ui and "AccountManager.set_display_name" in ui,
      "display name UI calls account manager")
for key in ["master_volume", "music_volume", "sfx_volume", "camera_sensitivity",
             "subtitles", "touch_controls", "reduced_motion"]:
    check(key in settings and key in ui, f"setting {key} is defined and represented in UI")
check("_apply_audio_settings" in settings and "AudioServer" in settings,
      "audio settings are applied to available audio buses")
check("account_identity" in save and "settings_snapshot" in save,
      "profile snapshots contain identity/settings")
check("SettingsManager.import_snapshot" in save,
      "profile load restores validated settings")
check("gameplay_loop_state" in main and "gameplay_loop.export_state()" in main,
      "main profile persists gameplay-loop state")
check("gameplay_loop.mission_completed.connect" in main,
      "main connects mission rewards to handler")
check("gameplay_loop.report_collection" in main,
      "resource pickups feed missions/expeditions")
check("base_development.export_state()" in main and "technology_tree.export_state()" in main,
      "base and research snapshots are included")
check("tests/test_account_settings_foundations.gd" in workflow,
      "CI includes account/settings GDScript test")
check("tests/integration_audit.py" in workflow,
      "CI includes this integration audit")

failures = sum(not ok for ok, _ in checks)
for ok, label in checks:
    print(("PASS" if ok else "FAIL") + ": " + label)
print(f"INTEGRATION AUDIT: {len(checks)-failures} passed, {failures} failed")
sys.exit(1 if failures else 0)
