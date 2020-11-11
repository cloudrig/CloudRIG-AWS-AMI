# CloudRIG - Gaming apps installation module

Import-Module "$PSScriptRoot\Common"

Function Install-GPU
{
    Install-GPUDrivers
    Disable-Devices
    Enable-NVFBC
}

Function Install-GPUDrivers {
    # Execute the GPU Updater in silent mode
    cd $env:USERPROFILE\AppData\Roaming\CloudRIGLoader
    & "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1" -Confirm false -DoNotReboot true
}

Function Disable-Devices {
    Write-Output "Disabling not required devices"
    Write-host "  * Disabling audio..."
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'

    Write-host "  * Disabling generic monitors..."
    Get-PnpDevice| where {$_.friendlyname -like "Microsoft Basic Display Adapter" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice| where {$_.friendlyname -like "Generic Non-PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice| where {$_.friendlyname -like "Generic PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8*"'
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1D0F&DEV_1111*"'

    # delete the basic display adapter's drivers (since some games still insist on using the basic adapter)
    takeown /f C:\Windows\System32\Drivers\BasicDisplay.sys
    icacls C:\Windows\System32\Drivers\BasicDisplay.sys /grant "$env:username`:F"
    move C:\Windows\System32\Drivers\BasicDisplay.sys C:\Windows\System32\Drivers\BasicDisplay.old
}

Function Enable-NVFBC {
    & "$CloudRIGInstallBaseDir\Apps\NvFBCEnable\NvFBCEnable.exe" -enable -noreset | Out-Null
}