[CmdletBinding()]
param(
    [switch]$SystemStartup,
    [string]$SyncthingPath
)

Write-Host "Syncthing Auto-Setup Script" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Auto-detect user info
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$UserProfile = $env:USERPROFILE

Write-Host "Current User: $CurrentUser" -ForegroundColor Green
Write-Host "User Profile: $UserProfile" -ForegroundColor Green

function Find-SyncthingExecutable {
    Write-Host "Searching for syncthing.exe..." -ForegroundColor Yellow

    # Method 1: Check PATH
    $PathResult = Get-Command syncthing.exe -ErrorAction SilentlyContinue
    if ($PathResult) {
        Write-Host "Found in PATH: $($PathResult.Source)" -ForegroundColor Green
        return $PathResult.Source
    }

    # Method 2: Check common locations
    $SearchPaths = @(
        "$env:USERPROFILE\syncthing\syncthing.exe",
        "$env:LOCALAPPDATA\Syncthing\syncthing.exe",
        "$env:ProgramFiles\Syncthing\syncthing.exe",
        "${env:ProgramFiles(x86)}\Syncthing\syncthing.exe",
        "$env:USERPROFILE\Desktop\syncthing.exe",
        "$env:USERPROFILE\Downloads\syncthing.exe",
        "$PSScriptRoot\syncthing.exe"
    )

    foreach ($Path in $SearchPaths) {
        if (Test-Path $Path) {
            Write-Host "Found at: $Path" -ForegroundColor Green
            return $Path
        }
    }

    # Method 3: Search recursively in user profile (limited depth)
    Write-Host "Searching user profile..." -ForegroundColor Yellow
    $Found = Get-ChildItem -Path $env:USERPROFILE -Recurse -Name "syncthing.exe" -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Found) {
        $FoundPath = Join-Path $env:USERPROFILE $Found
        Write-Host "Found via search: $FoundPath" -ForegroundColor Green
        return $FoundPath
    }

    return $null
}

# Find Syncthing if path not provided
if (-not $SyncthingPath) {
    $SyncthingPath = Find-SyncthingExecutable
}

if (-not $SyncthingPath -or -not (Test-Path $SyncthingPath)) {
    do {
        $SyncthingPath = Read-Host "Please enter the full path to syncthing.exe"
    } while (-not (Test-Path $SyncthingPath))
}

Write-Host "Using Syncthing at: $SyncthingPath" -ForegroundColor Green

# Determine startup method
if (-not $SystemStartup) {
    $Choice = Read-Host "Start at (1) User login or (2) System boot? [1]"
    $SystemStartup = ($Choice -eq "2")
}

try {
    # Create task components
    $TaskName = "Syncthing"
    $Action = New-ScheduledTaskAction -Execute $SyncthingPath -Argument "--no-console --no-browser"

    if ($SystemStartup) {
        $Trigger = New-ScheduledTaskTrigger -AtStartup
        $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        Write-Host "Creating system startup task..." -ForegroundColor Yellow
    } else {
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $Principal = New-ScheduledTaskPrincipal -UserId $CurrentUser -LogonType Interactive
        Write-Host "Creating user login task..." -ForegroundColor Yellow
    }

    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

    # Register the task
    $Task = Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force

    Write-Host "✓ Task '$TaskName' created successfully!" -ForegroundColor Green

    # Show task info
    $TaskInfo = Get-ScheduledTask -TaskName $TaskName
    Write-Host "`nTask Details:" -ForegroundColor Cyan
    Write-Host "Name: $($TaskInfo.TaskName)"
    Write-Host "State: $($TaskInfo.State)"
    Write-Host "Trigger: $($TaskInfo.Triggers[0].CimClass.CimClassName)"

    # Ask to start now
    $StartNow = Read-Host "`nStart Syncthing now? (y/n) [y]"
    if ($StartNow -ne 'n') {
        Start-ScheduledTask -TaskName $TaskName
        Write-Host "✓ Task started!" -ForegroundColor Green
    }

} catch {
    Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
    Write-Host "Try running PowerShell as Administrator" -ForegroundColor Red
}

Write-Host "`nUseful commands:" -ForegroundColor Cyan
Write-Host "View task: Get-ScheduledTask -TaskName 'Syncthing'"
Write-Host "Start task: Start-ScheduledTask -TaskName 'Syncthing'"
Write-Host "Remove task: Unregister-ScheduledTask -TaskName 'Syncthing'"