# CloudRIG - Gaming apps installation module

Import-Module "$PSScriptRoot\Common"

Function Install-GPU
{
    Write-Host "Preparing GPU..."
    Write-Progress -Activity "Preparing GPU..." -CurrentOperation "Install drivers (1/3)" -PercentComplete 0
    Install-GPUDrivers
    Write-Progress -Activity "Preparing GPU..." -CurrentOperation "Disable devices (2/3)" -PercentComplete 80
    Disable-Devices
    Write-Progress -Activity "Preparing GPU..." -CurrentOperation "Enable NvFBC (3/3)" -PercentComplete 95
    Enable-NVFBC
    Write-Progress -Activity "Preparing GPU..." -CurrentOperation "Done" -PercentComplete 100
}

Function Install-GPUDrivers {
    # Execute the GPU Updater in silent mode
    cd $env:USERPROFILE\AppData\Roaming\CloudRIGLoader
    & "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1" -Confirm false -DoNotReboot true
}

Function Disable-Devices {
    Write-Output "Disabling not required devices"
    Write-host "  * Disabling audio..."
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'

    Write-host "  * Disabling generic monitors..."
    Get-PnpDevice| where {$_.friendlyname -like "Microsoft Basic Display Adapter" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice| where {$_.friendlyname -like "Generic Non-PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice| where {$_.friendlyname -like "Generic PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8*"'
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1D0F&DEV_1111*"'
}

Function Enable-NVFBC {
    Write-Host "`  * nvfbcenable.exe" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/nvidia/NvFBCEnable.zip" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\NvFBCEnable.zip" | Out-Null
    Expand-Archive -LiteralPath "$global:CloudRIGInstallBaseDir\Apps\NvFBCEnable.zip" -DestinationPath "$global:CloudRIGInstallBaseDir\Apps\NvFBCEnable"
    & "$global:CloudRIGInstallBaseDir\Apps\NvFBCEnable\NvFBCEnable.exe" -enable -noreset | Out-Null
    Write-Host "`  - Success!"
}