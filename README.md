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
[MIT License](https://opensource.org/licenses/MIT)

## Acknowledgements
- Original concept by Chad Miller