# Define the path to the wallpaper image
$WallpaperPath = "C:\Hold\LosLocos.jpg"

# Set registry values for wallpaper style to "Fill"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 10
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value 0

# Refresh the desktop wallpaper
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# SPI_SETDESKWALLPAPER action, update INI file, and send the change to the system
[Wallpaper]::SystemParametersInfo(20, 0, $WallpaperPath, 2)
