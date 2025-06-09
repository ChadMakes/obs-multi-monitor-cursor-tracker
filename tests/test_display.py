import importlib.util
import sys
import types
from pathlib import Path
import pytest
import ctypes

@pytest.fixture(scope="module")
def tracker_module():
    dummy = types.ModuleType("dummy")
    for name in ["obspython", "win32api", "win32gui"]:
        sys.modules.setdefault(name, dummy)
    if not hasattr(ctypes, "windll"):
        ctypes.windll = types.SimpleNamespace()
    spec = importlib.util.spec_from_file_location(
        "obs_cursor_tracker",
        Path(__file__).resolve().parents[1] / "obs-cursor-tracker.py",
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def test_get_display_number_parses_display_strings(tracker_module):
    assert tracker_module.get_display_number({"Device": r"\\.\\DISPLAY2"}) == 2
    assert tracker_module.get_display_number({"Device": "DISPLAY3"}) == 3

def test_get_display_number_defaults_to_one_on_parse_error(tracker_module):
    assert tracker_module.get_display_number({"Device": "UNKNOWN"}) == 1
