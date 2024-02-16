# Define the CP folder path on the C: drive
$CPFolderPath = "C:\CP"

# Create the CP folder if it does not already exist
if (-not (Test-Path -Path $CPFolderPath)) {
    New-Item -ItemType Directory -Path $CPFolderPath
}

# Download SmartConsole.exe from blob storage and place it in the CP folder
$SmartConsoleExeUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/Check_Point_SmartConsole_R81_20_jumbo_HF_B651_Win.exe"
$SmartConsoleExePath = Join-Path -Path $CPFolderPath -ChildPath "SmartConsole.exe"
Invoke-WebRequest -Uri $SmartConsoleExeUrl -OutFile $SmartConsoleExePath

# Download MobaXterm_Portable_v23.6.zip from blob storage and place it in the CP folder
$MobaXtermUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/MobaXterm_Portable_v23.6.zip"
$MobaXtermPath = Join-Path -Path $CPFolderPath -ChildPath "MobaXterm_Portable_v23.6.zip"
Invoke-WebRequest -Uri $MobaXtermUrl -OutFile $MobaXtermPath
Expand-Archive -LiteralPath $MobaXtermPath -DestinationPath $CPFolderPath

# Create a URL shortcut in the CP folder pointing to www.checkpoint.com
$ShortcutPath = Join-Path -Path $CPFolderPath -ChildPath "CheckPoint.url"
$URL = "http://www.checkpoint.com"

$Shortcut = New-Object -ComObject WScript.Shell
$ShortcutCreate = $Shortcut.CreateShortcut($ShortcutPath)
$ShortcutCreate.TargetPath = $URL
$ShortcutCreate.Save()

# Setup the scheduled task

$TaskName = "CopyCPFilesToCpuserDesktop"
$TaskAction = New-ScheduledTaskAction -Execute "C:\Windows\System32\cmd.exe" -Argument "/c copy C:\CP\*.* C:\Users\cpuser\Desktop\"
$TaskTrigger = New-ScheduledTaskTrigger -AtLogon
$TaskUser = "SYSTEM"
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1) -StartWhenAvailable

# Register the task to run under the SYSTEM account, ensuring it's applicable to any user logging on
Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal (New-ScheduledTaskPrincipal -UserId $TaskUser -LogonType ServiceAccount -RunLevel Highest) -Settings $TaskSettings
