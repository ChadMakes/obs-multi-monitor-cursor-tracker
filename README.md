# OBS Multi-Monitor Cursor Tracker

This OBS Studio script automatically switches between multiple Display Capture sources based on which monitor the mouse cursor is on. It's designed for multi-monitor setups where you want to show the monitor that's currently being interacted with.

## Features
- Automatically detects cursor position across multiple monitors
- Switches OBS Studio display scenes based on cursor location
- Easy setup and configuration

## Installer
[Download the Auto Installer for OBS Multi-Monitor Cursor Tracker](https://github.com/ChadMakes/obs-multi-monitor-cursor-tracker/releases/download/V1.1.0/OBS.Cursor.Tracker.Setup.exe)

## Manual Installation
1. Download the `obs-cursor-tracker.py` file from this repository.
2. In OBS Studio, go to Tools > Scripts.
3. Click the "+" button and select the downloaded Python script.

## Improvements i've made
What changes have I done?
1. Improved the performance of the cursor tracking by reducing the interval from 200 ms to 250 ms.
2. Added a check for the active display. If the cursor is not on the active display, it will not be tracked.
3. Added a check for the active display in the script_update function. If the cursor is not on the active display, the script will not start tracking the cursor.
4. Added a check for the active display in the script_unload function. If the cursor is not on the active display, the script will stop tracking the cursor.
5. This script will now track the cursor position on all monitors, and it will only start tracking the cursor if the cursor is on the active display. If the cursor is not on the active display, the script will stop tracking the cursor.
6. Added transitions for between the scene changes, the selected transition in OBS will be played.

## Usage
1. Create Display Capture sources in your OBS scene for each monitor.
2. Name these sources exactly as "Display 1", "Display 2", etc.
3. Ensure the numbers match your Windows Display Settings.
4. Run the script in OBS to automatically switch between displays based on cursor position.

## Requirements
- OBS Studio
- Python 3.6 or higher
- pywin32 module (`pip install pywin32`)

## Contributing
Contributions, issues, and feature requests are welcome!

## License
Copyright (c) 2024 ChadMakes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Acknowledgements
- Made by ChadMakes aka Chad Miller
- Improved by wyvern800