# Syncthing Autostart

An one-time-run PowerShell helper script that registers a Windows Scheduled Task so Syncthing can start automatically in the background without showing a console window.

## What the script does

- Locates `syncthing.exe` automatically (checks `PATH`, common install folders, and performs a shallow search in your profile).
- Prompts you for the desired startup mode:
  - **User logon** (runs as your account whenever you sign in).
  - **System boot** (runs as `SYSTEM` during machine startup; requires elevation).
- Registers a Scheduled Task named **`Syncthing`** with sensible defaults (`--no-console --no-browser`, runs even on battery, etc.).
- Optionally starts the task immediately.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-SystemStartup` | Switch | Skips the prompt and configures the task to run as `SYSTEM` when Windows boots. Run PowerShell as Administrator when using this option. |
| `-SyncthingPath <string>` | String | Provide an explicit path to `syncthing.exe`. If omitted, the script tries to find it for you or asks interactively. |

You can combine the parameters for non-interactive automation:

```powershell
& ".\syncthing.ps1" -SystemStartup -SyncthingPath "C:\Apps\Syncthing\syncthing.exe"
```

## Prerequisites

- Windows with PowerShell 5.1 or later.
- Syncthing binary (`syncthing.exe`). Place it somewhere accessible (any folder, including your profile or `Program Files`).
- Administrator rights **only** if you want the task to run under `SYSTEM` at boot.

## Running the script

1. Open PowerShell in the folder containing `syncthing.ps1` (elevated if you plan to use `-SystemStartup`).
2. Execute:

    ```powershell
    .\syncthing.ps1
    ```

3. Respond to the prompts:
   - Confirm or supply the Syncthing executable path if it is not auto-detected.
   - Choose whether to start Syncthing at user login or system boot.
   - Decide whether to launch the scheduled task immediately.

When the task is created successfully you will see a green confirmation message.

## Managing the scheduled task

Use these commands in PowerShell to manage the task afterwards:

```powershell
# Check current status
Get-ScheduledTask -TaskName 'Syncthing'

# Start Syncthing manually
Start-ScheduledTask -TaskName 'Syncthing'

# Remove the scheduled task if no longer needed
Unregister-ScheduledTask -TaskName 'Syncthing' -Confirm:$false
```

## Troubleshooting tips

- If the script reports `Failed to create scheduled task`, rerun PowerShell as Administrator.
- Ensure the Execution Policy allows scripts (`Set-ExecutionPolicy RemoteSigned` if required).
- Verify the supplied path to `syncthing.exe` is correct and accessible to the chosen account.

## Removing autostart entirely

To stop Syncthing from auto-starting, either remove the scheduled task (see above) or rerun the script and choose to delete/replace the task when prompted.
