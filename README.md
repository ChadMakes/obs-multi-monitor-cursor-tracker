# OBS Multi-Monitor Cursor Tracker

This OBS Studio script automatically switches between multiple Display Capture sources based on which monitor the mouse cursor is on. It's designed for multi-monitor setups where you want to show the monitor that's currently being interacted with.

## Features
- Automatically detects cursor position across multiple monitors
- Switches OBS Studio display capture sources based on cursor location
- Easy setup and configuration

## Installation
1. Download the `obs-cursor-tracker.py` file from this repository.
2. In OBS Studio, go to Tools > Scripts.
3. Click the "+" button and select the downloaded Python script.

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