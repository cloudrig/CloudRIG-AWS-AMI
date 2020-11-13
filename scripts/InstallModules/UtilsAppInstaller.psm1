# CloudRIG - Prepare Windows Server for gaming

Import-Module "$PSScriptRoot\Common"

Function Install-UtilsApp {
    Write-Host "Installing utils applications..."
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Prepare (1/14)" -PercentComplete 0
    if((Test-Path -Path $global:CloudRIGInstallBaseDir\Apps) -eq $true) {} Else {New-Item -Path $global:CloudRIGInstallBaseDir\Apps -ItemType directory | Out-Null}
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Chocolatey (2/14)" -PercentComplete 2
    Install-Chocolatey
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "OpenSSL (3/14)" -PercentComplete 7
    Install-OpenSSL
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "CloudRIG GPU updater tool (4/14)" -PercentComplete 10
    Install-GPUUpdater
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "7Zip (5/14)" -PercentComplete 15
    Install-7Zip
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "DirectX (6/14)" -PercentComplete 19
    Install-DirectX
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "VCRedist (7/14)" -PercentComplete 25
    Install-VCRedist
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Google Chrome (8/14)" -PercentComplete 35
    Install-GoogleChrome
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "VB Cable (9/14)" -PercentComplete 45
    Install-VBCable
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Razer Surround (9/14)" -PercentComplete 55
    Install-RazerSurround
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "DevCon (10/14)" -PercentComplete 60
    Install-DevCon
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "PicoTorrent (11/14)" -PercentComplete 62
    Install-PicoTorrent
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Controller support (12/14)" -PercentComplete 70
    Install-ControllerDriver
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Windows features (13/14)" -PercentComplete 76
    Enable-WindowsFeatures
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "CloudRIG helper tools (14/14)" -PercentComplete 90
    Copy-CloudRIGScripts
    Install-AutoShutdownShortcut
    Install-OneHourWarningShortcut
    Write-Progress -Activity "Installing utils applications..." -CurrentOperation "Done" -PercentComplete 100
}

Function Install-Chocolatey
{
    Write-Host "`  * Chocolatey..." -NoNewline
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
    Write-Host "`  - Success!"
}

Function Install-OpenSSL {
    Write-Host "`  * OpenSSL" -NoNewLine
    choco install openssl /y | Out-Null
    Write-host "`  - Success!"
}

Function Install-GPUUpdater
{
    Write-Host "  * GPU Update tool" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/cloudrig/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1")
    Unblock-File -Path "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1"
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\GPU-Update.ico) -eq $true) {} Else {Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\GPU-Update.ico -Destination $ENV:APPDATA\CloudRIGLoader}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\GPU Updater.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.IconLocation = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU-Update.ico, 0";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "GPU Updater shortcut";
    $ShortCut.Save()
    Write-Host "`  - Success!"
}

Function Enable-WindowsFeatures
{
    Write-Host "  * Windows Direct Play" -NoNewline
    Install-WindowsFeature Direct-Play | Out-Null
    Write-host "`  - Success!"
    Write-Host "  * Windows Net Framework" -NoNewline
    Install-WindowsFeature Net-Framework-Core | Out-Null
    Write-Host "`  - Success!"
}

Function Install-DirectX
{
    Write-Host "  * DirectX" -NoNewline
    if((Test-Path -Path "$global:CloudRIGInstallBaseDir\DirectX") -eq $true) {} Else {New-Item -Path "$global:CloudRIGInstallBaseDir\DirectX" -ItemType directory | Out-Null}
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe", "$global:CloudRIGInstallBaseDir\Apps\directx_Jun2010_redist.exe")
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\directx_jun2010_redist.exe" -ArgumentList "/T:$global:CloudRIGInstallBaseDir\DirectX /Q" -Wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -Wait
    Remove-Item -Path $global:CloudRIGInstallBaseDir\DirectX -force -Recurse
    Write-Host "`  - Success!"
}

Function Install-GoogleChrome
{
    Write-Host "  * Chrome" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi", "$global:CloudRIGInstallBaseDir\Apps\googlechromestandaloneenterprise64.msi")
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/kolbicz/SetDefaultBrowser.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\SetDefaultBrowser.exe" | Out-Null

    # Set Chrome as the default browser
    start-Process -filepath "C:\Windows\System32\msiexec.exe" -ArgumentList "/qn /i `"$global:CloudRIGInstallBaseDir\Apps\googlechromestandaloneenterprise64.msi`"" -Wait
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\SetDefaultBrowser.exe" -ArgumentList 'HKLM "Google Chrome"' -Wait
    $Target = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $KeyPath1  = "HKLM:\SOFTWARE\Classes"
    $KeyPath2  = "*"
    $KeyPath3  = "shell"
    $KeyPath4  = "{:}"
    $ValueName = "ExplorerCommandHandler"
    $ValueData = (Get-ItemProperty ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\" + "CommandStore\shell\Windows.taskbarpin")).ExplorerCommandHandler

    $Key2 = (Get-Item $KeyPath1).OpenSubKey($KeyPath2, $true)
    $Key3 = $Key2.CreateSubKey($KeyPath3, $true)
    $Key4 = $Key3.CreateSubKey($KeyPath4, $true)
    $Key4.SetValue($ValueName, $ValueData)

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.Namespace((Get-Item $Target).DirectoryName)
    $Item = $Folder.ParseName((Get-Item $Target).Name)
    $Item.InvokeVerb("{:}")

    $Key3.DeleteSubKey($KeyPath4)
    if ($Key3.SubKeyCount -eq 0 -and $Key3.ValueCount -eq 0) {
        $Key2.DeleteSubKey($KeyPath3)
    }

    Write-Host "`  - Success!"
}

Function Install-7Zip
{
    Write-Host "  * 7Zip" -NoNewline
    $url = Invoke-WebRequest -Uri https://www.7-zip.org/download.html
    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/$($($($url.Links | Where-Object outertext -Like "Download")[1]).OuterHTML.split('"')[1])" ,"$global:CloudRIGInstallBaseDir\Apps\7zip.exe") | Out-Null
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\7zip.exe" -ArgumentList '/S /D="C:\Program Files\7-Zip"' -Wait
    Write-Host "`  - Success!"
}

Function Install-VCRedist
{
    Write-Host "  * VC Redist" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2010_x86.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2010_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x64.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2015_x64.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x86.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2017_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x86.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2015_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x64.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2017_x64.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2019_x86.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2019_x86.exe" | Out-Null
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2010_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2015_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2015_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2017_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2017_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\vc_redist_2019_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Write-Host "`  - Success!"
}

Function Install-RazerSurround
{
    Write-Host "  * Razer Surround" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("http://rzr.to/surround-pc-download", "$global:CloudRIGInstallBaseDir\Apps\razer-surround-driver.exe")
    cmd.exe /c "`"C:\Program Files\7-Zip\7z.exe`" x $global:CloudRIGInstallBaseDir\Apps\razer-surround-driver.exe -o$global:CloudRIGInstallBaseDir\Apps\razer-surround-driver -y" | Out-Null
    $InstallerManifest = "$global:CloudRIGInstallBaseDir\Apps\razer-surround-driver\`$TEMP\RazerSurroundInstaller\InstallerManifest.xml"
    $regex = '(?<=<SilentMode>)[^<]*'
    (Get-Content $InstallerManifest) -replace $regex, 'true' | Set-Content $InstallerManifest -Encoding UTF8
    $OriginalLocation = Get-Location
    Set-Location -Path "$global:CloudRIGInstallBaseDir\Apps\razer-surround-driver\`$TEMP\RazerSurroundInstaller\"
    Start-Process RzUpdateManager.exe
    Set-Location $OriginalLocation
    Set-Service -Name audiosrv -StartupType Automatic
    Write-Host "`  - Success!"
}

Function Install-VBCable
{
    Write-Host "  * VB Audio - Cable" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/vb-audio/VBCABLE_Driver_Pack43.zip" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver.zip" | Out-Null

    Expand-Archive -LiteralPath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver.zip" -DestinationPath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\" | Out-Null
    (Get-AuthenticodeSignature -FilePath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbaudio_cable64_win7.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbcable.cer" | Out-Null
    Import-Certificate -FilePath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\VBCABLE_Setup_x64.exe" -ArgumentList '-h','-i','-H','-n' -wait | Out-Null
    Write-Host "`  - Success!"
}

Function Install-ControllerDriver
{
    if ((gwmi win32_operatingsystem | % caption) -like '*Windows Server 2019*') {
        Write-Host "`  * Xbox Accessories 1.2 (controller support - Windows Server 2019 only)"  -NoNewline
        Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/Xbox360_64Eng.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng.exe" | Out-Null
        if((Test-Path -Path $global:CloudRIGInstallBaseDir\Drivers) -eq $true) {} Else {New-Item -Path $global:CloudRIGInstallBaseDir\Drivers -ItemType Directory | Out-Null}
        cmd.exe /c "`"C:\Program Files\7-Zip\7z.exe`" x $global:CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng.exe -o$global:CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng -r -y" | Out-Null
        cmd.exe /c "`"PNPUtil.exe`" /add-driver $global:CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng\xbox360\setup64\files\driver\win7\xusb21.inf" | Out-Null
        Write-Host "`  - Success!"
    }
}

Function Install-DevCon
{
    Write-Host "`  * Devcon..." -NoNewline
    if((Test-Path -Path "$global:CloudRIGInstallBaseDir\Devcon") -eq $true) {} Else {New-Item -Path "$global:CloudRIGInstallBaseDir\Devcon" -ItemType Directory | Out-Null}
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/devcon.exe" -LocalFile "$global:CloudRIGInstallBaseDir\Devcon\devcon.exe" | Out-Null
    Write-Host "`  - Success!"
}

Function Install-PicoTorrent
{
    Write-Host "  * PicoTorrent" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/picotorrent/PicoTorrent-0.23.0-x64.exe	" -LocalFile "$global:CloudRIGInstallBaseDir\Apps\PicoTorrent-x64.exe" | Out-Null
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\PicoTorrent-x64.exe" -ArgumentList '/install','/quiet','/norestart' -wait | Out-Null
    Write-Host "`  - Success!"
}

Function Copy-CloudRIGScripts {
    Write-Host "`  * CloudRIG Helper scripts" -NoNewline
    if((Test-Path -Path "$ENV:APPDATA\CloudRIGLoader") -eq $true) {} Else {New-Item -Path "$ENV:APPDATA\CloudRIGLoader" -ItemType Directory | Out-Null}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\clear-proxy.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\clear-proxy.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateClearProxyScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\CreateClearProxyScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\Automatic-Shutdown.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\Automatic-Shutdown.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\CreateAutomaticShutdownScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\GPU-Update.ico) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\GPU-Update.ico" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\CreateOneHourWarningScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\WarningMessage.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\WarningMessage.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\ShowDialog.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\ShowDialog.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\OneHour.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\OneHour.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\PrepareInstanceOnStartup.ps1) -eq $true) {} Else {Move-Item -Path "$global:CloudRIGInstallBaseDir\Resources\PrepareInstanceOnStartup.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    Write-Host "`  - Success!"
}

Function Install-AutoShutdownShortcut {
    Write-Host "`  * Auto Shutdown Shortcut..." -NoNewline
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\Setup Auto Shutdown.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "ClearProxy shortcut";
    $ShortCut.Save()
    Write-Host "`  - Success!"
}

Function Install-OneHourWarningShortcut {
    Write-Host "`  * One Hour Warning Shortcut..." -NoNewline
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    if((Test-Path "$ENV:APPDATA\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1") -eq $true) {} Else {Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\CreateOneHourWarningScheduledTask.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\Setup One Hour Warning.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "OneHourWarning shortcut";
    $ShortCut.Save()
    Write-Host "`  - Success!"
}
