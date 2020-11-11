# CloudRIG - Main installer

Import-Module "$PSScriptRoot\InstallModules\UtilsAppInstaller"
Import-Module "$PSScriptRoot\InstallModules\ConfigureWindowsForGaming"
Import-Module "$PSScriptRoot\InstallModules\GamingAppInstaller"
Import-Module "$PSScriptRoot\InstallModules\GPUPreparation"
Import-Module "$PSScriptRoot\InstallModules\CloudProviderSpecificSetup"

Function Install-EntryPoint
{
    Param (
        [String] $CloudRIGBaseFolder
    )
    $CloudRIGInstallBaseDir = $CloudRIGBaseFolder

    Install-Env

    Install-UtilsApp
    Install-ConfigurationWindowsForGaming
    Install-GamingApp
    Install-GPU
    Install-CloudProviderSpecificSetup

    Remove-Env
}

Function Install-Env {
    if((Test-Path -Path $env:USERPROFILE\AppData\Roaming\CloudRIGLoader) -eq $true) {} Else {New-Item -Path $env:USERPROFILE\AppData\Roaming\CloudRIGLoader -ItemType directory | Out-Null}
}

Function Remove-Env {
    Write-Output "Cleaning up..."
    Remove-Item -Path "$CloudRIGInstallBaseDir" -force -Recurse -ErrorAction SilentlyContinue
    Write-Output "Removing recent files..."
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force | Out-Null
}
