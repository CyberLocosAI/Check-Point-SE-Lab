# Define the paths to the wallpaper images
$WallpaperPaths = @(
    "C:\Hold\LosLocos.jpg",
    "C:\Hold\1.jpg", 
    "C:\Hold\2.jpg", 
    "C:\Hold\3.jpg",
    "C:\Hold\4.jpg", 
    "C:\Hold\5.jpg",
    "C:\Hold\6.jpg", 
    "C:\Hold\7.jpg",
    "C:\Hold\8.jpg", 
    "C:\Hold\9.jpg"  
    # Add more paths as needed
)

# Select a random wallpaper path from the array
$WallpaperPath = Get-Random -InputObject $WallpaperPaths

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
