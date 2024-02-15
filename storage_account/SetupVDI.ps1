# Define the CP folder path on the C: drive
$CPFolderPath = "C:\CP"

# Create the CP folder if it does not already exist
if (-not (Test-Path -Path $CPFolderPath)) {
    New-Item -ItemType Directory -Path $CPFolderPath
}

# Download SmartConsole.exe from blob storage and place it in the CP folder
$SmartConsoleExeUrl = "https://vmsetupscriptstorage.blob.core.windows.net/vm-setup-scripts/SmartConsole.exe"
$SmartConsoleExePath = Join-Path -Path $CPFolderPath -ChildPath "SmartConsole.exe"
Invoke-WebRequest -Uri $SmartConsoleExeUrl -OutFile $SmartConsoleExePath

# Create a URL shortcut in the CP folder pointing to www.checkpoint.com
$ShortcutPath = Join-Path -Path $CPFolderPath -ChildPath "CheckPoint.url"
$URL = "http://www.checkpoint.com"

$Shortcut = New-Object -ComObject WScript.Shell
$ShortcutCreate = $Shortcut.CreateShortcut($ShortcutPath)
$ShortcutCreate.TargetPath = $URL
$ShortcutCreate.Save()

# Optional: Add here any additional configuration or file manipulation commands
