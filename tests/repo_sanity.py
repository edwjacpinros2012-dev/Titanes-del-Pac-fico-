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
check("docs/DIAGNOSTICO_COMUNICACION_QA_REFERENCIAS.md" in readme, "README links system QA diagnostic")
check((ROOT / "data").is_dir(), "data directory exists")
check((ROOT / "scripts").is_dir(), "scripts directory exists")
check((ROOT / "docs").is_dir(), "docs directory exists")

for ok, label in checks:
    print(("PASS" if ok else "FAIL") + ": " + label)
failed = sum(not ok for ok, _ in checks)
print(f"REPOSITORY SANITY: {len(checks)-failed} passed, {failed} failed")
sys.exit(1 if failed else 0)
