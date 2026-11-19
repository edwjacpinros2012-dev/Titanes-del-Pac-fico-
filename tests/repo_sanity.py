#!/usr/bin/env python3
"""Small repository sanity checks; intentionally uses only Python's standard library."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
checks = []

def check(condition: bool, label: str) -> None:
    checks.append((condition, label))

project = (ROOT / "project.godot").read_text(encoding="utf-8")
readme = (ROOT / "README.md").read_text(encoding="utf-8")
workflow = (ROOT / ".github/workflows/godot-validation.yml").read_text(encoding="utf-8")
check('run/main_scene="res://scenes/main.tscn"' in project, "project points to main scene")
check((ROOT / "scenes/main.tscn").is_file(), "main scene file exists")
check((ROOT / "scripts/main.gd").is_file(), "main gameplay script exists")
check((ROOT / "tests/test_core_logic.gd").is_file(), "Godot core test script exists")
check("Run core logic tests" in workflow, "CI includes core logic tests")
check("tests/repo_sanity.py" in workflow, "CI includes repository sanity script")
check("godot --headless --editor --path . --quit" in workflow, "CI imports Godot project")
check("godot --headless --path . --quit-after 10" in workflow, "CI smoke-runs main scene")
check((ROOT / "scripts/core/game_state.gd").is_file(), "core state script exists")
check((ROOT / "scripts/core/save_manager.gd").is_file(), "save manager script exists")
save_manager = (ROOT / "scripts/core/save_manager.gd").read_text(encoding="utf-8")
check("return snapshot if version >= 1 and version <= 2 else {}" in save_manager, "profile loader uses valid version fallback syntax")
check((ROOT / "scripts/gameplay/game_loop_manager.gd").is_file(), "integrated gameplay loop manager exists")
main_script = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
check("gameplay_loop.mission_completed.connect" in main_script, "main scene connects mission completion reward handler")
check("gameplay_loop.report_collection" in main_script, "resource collection feeds mission and expedition loop")
check("gameplay_loop_state" in main_script, "profile save includes gameplay loop state")
touch_script = (ROOT / "scripts/platform/platform_input.gd").read_text(encoding="utf-8")
check('"M", "expedition_toggle"' in touch_script, "touch controls include expedition action")
check("expedition_toggle" in main_script, "main script handles expedition input action")
check("docs/DIAGNOSTICO_COMUNICACION_QA_REFERENCIAS.md" in readme, "README links system QA diagnostic")
check((ROOT / "data").is_dir(), "data directory exists")
check((ROOT / "scripts").is_dir(), "scripts directory exists")
check((ROOT / "docs").is_dir(), "docs directory exists")


# Parse all project JSON data to catch malformed content early.
import json
json_files = sorted(ROOT.rglob("*.json"))
json_errors = []
for json_path in json_files:
    try:
        json.loads(json_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as error:
        json_errors.append(f"{json_path.relative_to(ROOT)}: {error}")
check(not json_errors, f"all {len(json_files)} JSON files parse")

# Supabase migration version prefixes must be unique and ordered.
migration_files = sorted((ROOT / "backend/supabase/migrations").glob("*.sql"))
migration_versions = [path.name.split("_", 1)[0] for path in migration_files]
check(len(migration_versions) == len(set(migration_versions)), "Supabase migration versions are unique")
check(migration_versions == sorted(migration_versions), "Supabase migration files sort by version")

# Confirm the main scene references the script and autoload paths exist.
main_scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
check("res://scripts/main.gd" in main_scene, "main scene references gameplay script")
for autoload_path in ("res://scripts/core/game_state.gd", "res://scripts/core/save_manager.gd"):
    check(autoload_path in project and (ROOT / autoload_path.replace("res://", "")).is_file(), f"autoload path exists: {autoload_path}")

for ok, label in checks:
    print(("PASS" if ok else "FAIL") + ": " + label)
failed = sum(not ok for ok, _ in checks)
print(f"REPOSITORY SANITY: {len(checks)-failed} passed, {failed} failed")
sys.exit(1 if failed else 0)
