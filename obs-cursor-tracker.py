import obspython as obs
import win32api
import win32gui
from ctypes import windll, Structure, c_long, byref
import sys
import threading
import time

class POINT(Structure):
    _fields_ = [("x", c_long), ("y", c_long)]

# Global variables
CURSOR_CHECK_INTERVAL_MS = 250  # Increased interval to 500 ms
active_display = None
display_sources = {}

def script_description():
    return """Multi-Monitor Cursor Tracking for OBS Studio
    
Created by Chad Miller & Updated by wyvern800

Usage Instructions:
1. Create two Scenes (One named Scene Display 1, and one named Scene Display 2, and so on if have more monitors) 
2- Add the Display Capture sources in all of your scenes for each monitor (One in Scene Display 1 and one in Scene Display 2).
3. Name these sources exactly as "Display 1", "Display 2", etc.
4. The number in the scene name should match the display number in Windows Display Settings (Scene Display 1, matches my monitor 1).

Scenes not changing?
Click on Refresh Sources button to refresh
"""


def script_update(settings):
    obs.timer_remove(check_cursor_position)
    start_cursor_tracking()  # Use threading to offload the cursor checking

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
        

# Global variable to track when the last transition started
last_transition_time = 0

def toggle_display_sources(current_display):
    global active_display, last_transition_time

    # Only toggle if the display is actually changing
    if current_display == active_display:
        return  # Don't switch if it's the same display

    # Get the current transition and its duration
    transition_source = obs.obs_frontend_get_current_transition()
    if transition_source is None:
        print("Debug: No transition found")
        return

    transition_duration = obs.obs_frontend_get_transition_duration()  # Get the transition duration
    current_time = time.time()

    # Check if the last transition is still in progress
    if (current_time - last_transition_time) < (transition_duration / 1000.0):
        print("Debug: Transition in progress, waiting...")
        return  # Don't switch scenes yet; wait for transition to finish

    # Set the transition in OBS
    obs.obs_frontend_set_current_transition(transition_source)
    
    # Delay to allow the transition to be set (optional)
    time.sleep(0.1)  # Short delay to ensure transition is applied

    # Fetch the scene source based on the current display
    scene_name = f"Scene {current_display}"
    scene_source = obs.obs_get_source_by_name(scene_name)

    if scene_source is not None:
        # Switch to the new scene
        obs.obs_frontend_set_current_scene(scene_source)
        print(f"Debug: Switched to {scene_name} with transition")
        obs.obs_source_release(scene_source)  # Release the source when done
        last_transition_time = time.time()  # Update last transition time
    else:
        print(f"Debug: Scene {scene_name} not found")

    active_display = current_display



def start_cursor_tracking():
    """Start a separate thread to handle cursor tracking."""
    tracking_thread = threading.Thread(target=cursor_tracking_loop)
    tracking_thread.daemon = True  # Daemon thread will exit when the main thread exits
    tracking_thread.start()

def cursor_tracking_loop():
    """Loop to periodically check the cursor position."""
    while True:
        check_cursor_position()
        time.sleep(CURSOR_CHECK_INTERVAL_MS / 1000)  # Sleep based on the interval in seconds

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

        # Start cursor tracking after loading the scene
        start_cursor_tracking()

    except Exception as e:
        print(f"Error in script_load: {str(e)}")

def script_properties():
    props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "button", "Refresh Display Scenes", refresh_display_sources)
    return props

def refresh_display_sources(props, prop):
    try:
        script_load(None)
    except Exception as e:
        print(f"Error in refresh_display_sources: {str(e)}")
    return True
