import obspython as obs
import win32api
import win32gui
from ctypes import windll, Structure, c_long, byref
import sys

class POINT(Structure):
    _fields_ = [("x", c_long), ("y", c_long)]

# Global variables
CURSOR_CHECK_INTERVAL_MS = 100
active_display = None
display_sources = {}

def script_description():
    return """Multi-Monitor Cursor Tracking for OBS Studio
    
Created by Chad Miller

Usage Instructions:
1. Create Display Capture sources in your scene for each monitor.

2. Name these sources exactly as "Display 1", "Display 2", etc.

3. The number in the source name should match the display number in Windows Display Settings."""

def script_update(settings):
    obs.timer_remove(check_cursor_position)
    obs.timer_add(check_cursor_position, CURSOR_CHECK_INTERVAL_MS)

def script_unload():
    obs.timer_remove(check_cursor_position)

def get_display_number(monitor_info):
    # Extract display number from device name
    device = monitor_info['Device']
    try:
        return int(device.split('DISPLAY')[-1])
    except ValueError:
        return 1  # Default to 1 if parsing fails

def check_cursor_position():
    global active_display
    cursor_pos = POINT()
    windll.user32.GetCursorPos(byref(cursor_pos))
    monitor = win32api.MonitorFromPoint((cursor_pos.x, cursor_pos.y))
    
    monitor_info = win32api.GetMonitorInfo(monitor)
    display_number = get_display_number(monitor_info)
    current_display = f"Display {display_number}"
    
    print(f"Debug: Cursor position - X: {cursor_pos.x}, Y: {cursor_pos.y}, Current Display: {current_display}")
    
    if current_display != active_display:
        print(f"Debug: Switching from {active_display} to {current_display}")
        toggle_display_sources(current_display)

def toggle_display_sources(current_display):
    global active_display
    
    for display, source in display_sources.items():
        enabled = (display == current_display)
        obs.obs_source_set_enabled(source, enabled)
        print(f"Debug: Setting {display} to {'enabled' if enabled else 'disabled'}")
    
    active_display = current_display

def script_load(settings):
    global display_sources
    display_sources.clear()
    
    print(f"Debug: Python version: {sys.version}")
    
    try:
        scene = obs.obs_frontend_get_current_scene()
        if scene is None:
            print("Debug: Current scene is None")
            return

        scene_source = obs.obs_scene_from_source(scene)
        if scene_source is None:
            print("Debug: Failed to get scene source")
            obs.obs_source_release(scene)
            return

        scene_items = obs.obs_scene_enum_items(scene_source)
        if scene_items is None:
            print("Debug: Failed to enumerate scene items")
            obs.obs_source_release(scene)
            return

        for item in scene_items:
            source = obs.obs_sceneitem_get_source(item)
            if source is not None:
                source_name = obs.obs_source_get_name(source)
                if source_name is not None and source_name.startswith("Display "):
                    display_sources[source_name] = source
                    print(f"Debug: Added source: {source_name}")
            else:
                print("Debug: Found a None source in scene items")

        obs.sceneitem_list_release(scene_items)
        obs.obs_source_release(scene)

        print(f"Debug: Total display sources found: {len(display_sources)}")
    except Exception as e:
        print(f"Error in script_load: {str(e)}")

def script_properties():
    props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "button", "Refresh Display Sources", refresh_display_sources)
    return props

def refresh_display_sources(props, prop):
    try:
        script_load(None)
    except Exception as e:
        print(f"Error in refresh_display_sources: {str(e)}")
    return True