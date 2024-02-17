# Define the CP folder path on the C: drive
$CPFolderPath = "C:\CP"

# Create the CP folder if it does not already exist
if (-not (Test-Path -Path $CPFolderPath)) {
    New-Item -ItemType Directory -Path $CPFolderPath
}

# Download custom wallpaper image and place it in the CP folder
$WallpaperUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/LosLocos.jpg"
$WallpaperPath = Join-Path -Path $CPFolderPath -ChildPath "LosLocos.jpg"
Invoke-WebRequest -Uri $WallpaperUrl -OutFile $WallpaperPath

# Download SmartConsole.exe from blob storage and place it in the CP folder
$SmartConsoleExeUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/Check_Point_SmartConsole_R81_20_jumbo_HF_B651_Win.exe"
$SmartConsoleExePath = Join-Path -Path $CPFolderPath -ChildPath "SmartConsole.exe"
Invoke-WebRequest -Uri $SmartConsoleExeUrl -OutFile $SmartConsoleExePath

# Download MobaXterm files from blob storage and place it in the CP folder
$MobaXtermUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/MobaXterm_Personal_23.6.exe"
$MobaXtermPath = Join-Path -Path $CPFolderPath -ChildPath "MobaXterm.exe"
Invoke-WebRequest -Uri $MobaXtermUrl -OutFile $MobaXtermPath

$MobaXtermUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/CygUtils64.plugin"
$MobaXtermPath = Join-Path -Path $CPFolderPath -ChildPath "CygUtils64.plugin"
Invoke-WebRequest -Uri $MobaXtermUrl -OutFile $MobaXtermPath

# Download wallpaper.ps1 from blob storage and place it in the CP folder
$WallpaperScriptUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/wallpaper.ps1"
$WallpaperScriptPath = Join-Path -Path $CPFolderPath -ChildPath "wallpaper.ps1"
Invoke-WebRequest -Uri $WallpaperScriptUrl -OutFile $WallpaperScriptPath

# Create a URL shortcut in the CP folder pointing to www.checkpoint.com
$ShortcutPath = Join-Path -Path $CPFolderPath -ChildPath "CheckPoint.url"
$URL = "http://www.checkpoint.com"
$Shortcut = New-Object -ComObject WScript.Shell
$ShortcutCreate = $Shortcut.CreateShortcut($ShortcutPath)
$ShortcutCreate.TargetPath = $URL
$ShortcutCreate.Save()

# Setup the scheduled task for file copy
$TaskName = "CopyCPFilesToCpuserDesktop"
$TaskAction = New-ScheduledTaskAction -Execute "C:\Windows\System32\cmd.exe" -Argument "/c copy C:\CP\*.* C:\Users\cpuser\Desktop\"
$TaskTrigger = New-ScheduledTaskTrigger -AtLogon
$TaskUser = "SYSTEM"
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1) -StartWhenAvailable
Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal (New-ScheduledTaskPrincipal -UserId $TaskUser -LogonType ServiceAccount -RunLevel Highest) -Settings $TaskSettings

# Setup the scheduled task to run the wallpaper script at user logon
$TaskName = "SetWallpaperAtLogon"
$TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\CP\wallpaper.ps1"
$TaskTrigger = New-ScheduledTaskTrigger -AtLogon -User "cpuser"
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1) -StartWhenAvailable

# Register the scheduled task
Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings -User "cpuser"