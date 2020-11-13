# CloudRIG - Main installer

Import-Module "$PSScriptRoot\InstallModules\UtilsAppInstaller"  -Force
Import-Module "$PSScriptRoot\InstallModules\ConfigureWindowsForGaming" -Force
Import-Module "$PSScriptRoot\InstallModules\GamingAppInstaller" -Force
Import-Module "$PSScriptRoot\InstallModules\GPUPreparation" -Force
Import-Module "$PSScriptRoot\InstallModules\CloudProviderSpecificSetup" -Force

Function Install-EntryPoint
{
    Param (
        [String] $CloudRIGBaseFolder
    )

    Install-Env

    Install-UtilsApp
    Install-ConfigurationWindowsForGaming
    Install-GamingApp
    Install-GPU
    Install-CloudProviderSpecificSetup

    Remove-Env
}

Function Install-Env {
    if((Test-Path -Path "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader") -eq $true) {} Else {New-Item -Path $env:USERPROFILE\AppData\Roaming\CloudRIGLoader -ItemType directory | Out-Null}
    if((Test-Path -Path "$global:CloudRIGInstallBaseDir\Apps") -eq $true) {} Else {New-Item -Path "$global:CloudRIGInstallBaseDir\Apps" -ItemType directory | Out-Null}
    if((Test-Path -Path "$global:CloudRIGInstallBaseDir\Drivers") -eq $true) {} Else {New-Item -Path "$global:CloudRIGInstallBaseDir\Drivers" -ItemType directory | Out-Null}
    if((Test-Path -Path "C:\CloudRIG\Logs\") -eq $true) {} Else {New-Item -Path "C:\CloudRIG\Logs\" -ItemType directory | Out-Null}
}

Function Remove-Env {
    Write-Output "Cleaning up..."
    Remove-Item -Path "$global:CloudRIGInstallBaseDir" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    Write-Output "Removing recent files..."
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
