# Syncthing Autostart

A simple PowerShell script to automatically start Syncthing in the background.

## Usage

1.  Place the `syncthing.ps1` script in a directory of your choice.
2.  Run the script from a PowerShell terminal:

    ```powershell
    .\syncthing.ps1
    ```

The script will start the Syncthing executable (`syncthing.exe`) without a console window. Make sure `syncthing.exe` is in your system's PATH or in the same directory as the script.

## Autostart on Login

To run this script automatically when you log in, you can create a shortcut to it in the Windows Startup folder.

1.  Press `Win + R` to open the Run dialog.
2.  Type `shell:startup` and press Enter. This will open the Startup folder.
3.  Create a new shortcut with the following target:

    ```
    powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\your\syncthing.ps1"
    ```

    Replace `C:\path\to\your\syncthing.ps1` with the actual path to the script.
