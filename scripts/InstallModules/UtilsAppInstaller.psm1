# CloudRIG - Prepare Windows Server for gaming

Import-Module "$PSScriptRoot\Common"

Function Install-UtilsApp {
    if((Test-Path -Path $CloudRIGInstallBaseDir\Apps) -eq $true) {} Else {New-Item -Path $CloudRIGInstallBaseDir\Apps -ItemType directory | Out-Null}
    Install-GPUUpdater
    Install-7Zip
    Install-DirectX
    Install-VCRedist
    Install-GoogleChrome
    Install-TightVNC
    Install-VBCable
    Install-RazerSurround
    Install-DevCon
    Install-NVFBCEnable
    Install-ControllerDriver
    Enable-WindowsFeatures
    Copy-CloudRIGScripts
    Install-AutoShutdownShortcut
    Install-OneHourWarningShortcut
}

Function Install-GPUUpdater
{
    Write-Host "  * GPU Update tool" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/cloudrig/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1")
    Unblock-File -Path "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1"
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\GPU Updater.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.IconLocation = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU-Update.ico, 0";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "GPU Updater shortcut";
    $ShortCut.Save()
    Write-host "`  - Success!"
}

Function Enable-WindowsFeatures
{
    Write-Host "  * Windows Direct Play" -NoNewline
    Install-WindowsFeature Direct-Play | Out-Null
    Write-host "`  - Success!"
    Write-Host "  * Windows Net Framework" -NoNewline
    Install-WindowsFeature Net-Framework-Core | Out-Null
    Write-host "`  - Success!"
}

Function Install-DirectX
{   Write-Host "$CloudRIGInstallBaseDir"
    Write-Host "  * DirectX" -NoNewline
    if((Test-Path -Path "$CloudRIGInstallBaseDir\DirectX") -eq $true) {} Else {New-Item -Path "$CloudRIGInstallBaseDir\DirectX" -ItemType directory | Out-Null}
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe", "$CloudRIGInstallBaseDir\Apps\directx_Jun2010_redist.exe")
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\directx_jun2010_redist.exe" -ArgumentList "/T:$CloudRIGInstallBaseDir\DirectX /Q" -Wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -Wait
    Remove-Item -Path $CloudRIGInstallBaseDir\DirectX -force -Recurse
    Write-host "`  - Success!"
}

Function Install-GoogleChrome
{
    Write-Host "  * Chrome" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi", "$CloudRIGInstallBaseDir\Apps\googlechromestandaloneenterprise64.msi")
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/kolbicz/SetDefaultBrowser.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\SetDefaultBrowser.exe" | Out-Null

    # Set Chrome as the default browser
    start-process -filepath "C:\Windows\System32\msiexec.exe" -ArgumentList '/qn /i "$CloudRIGInstallBaseDir\Apps\googlechromestandaloneenterprise64.msi"' -Wait
    Start-Process "$CloudRIGInstallBaseDir\Apps\SetDefaultBrowser.exe" -ArgumentList 'HKLM "Google Chrome"' -Wait
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

    Write-host "`  - Success!"
}

Function Install-7Zip
{
    Write-Host "  * 7Zip" -NoNewline
    $url = Invoke-WebRequest -Uri https://www.7-zip.org/download.html
    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/$($($($url.Links | Where-Object outertext -Like "Download")[1]).OuterHTML.split('"')[1])" ,"$CloudRIGInstallBaseDir\Apps\7zip.exe") | Out-Null
    Start-Process "$CloudRIGInstallBaseDir\Apps\7zip.exe" -ArgumentList '/S /D="C:\Program Files\7-Zip"' -Wait
    Write-host "`  - Success!"
}

Function Install-VCRedist
{
    Write-Host "  * VC Redist" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2010_x86.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2010_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x64.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2015_x64.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x86.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2017_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x86.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2015_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x64.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2017_x64.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2019_x86.exe" -LocalFile "$CloudRIGInstallBaseDir\Apps\vc_redist_2019_x86.exe" | Out-Null
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2010_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2015_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2015_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2017_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2017_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\vc_redist_2019_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Write-host "`  - Success!"
}

Function Install-TightVNC
{
    Write-Host "  * TightVNC" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile($(((Invoke-WebRequest -Uri https://www.tightvnc.com/download.php -UseBasicParsing).Links.OuterHTML -like "*Installer for Windows (64-bit)*").split('"')[1].split('"')[0]), "$CloudRIGInstallBaseDir\Apps\tightvnc.msi")
    $VncPassword = Get-RandomAlphanumericString -length 24
    Start-Process msiexec.exe -ArgumentList "/i $CloudRIGInstallBaseDir\Apps\TightVNC.msi /quiet /norestart ADDLOCAL=Server SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=$VncPassword SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=$VncPassword" -Wait
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $env:USERNAME | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "" | Out-Null
    if((Test-RegistryValue -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value AutoAdminLogin)-eq $true){Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null} Else {New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null}
    Write-host "`  - Success! [$VncPassword]"
}

Function Install-RazerSurround
{
    Write-Host "  * Razer Surround" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("http://rzr.to/surround-pc-download", "$CloudRIGInstallBaseDir\Apps\razer-surround-driver.exe")
    cmd.exe /c "`"C:\Program Files\7-Zip\7z.exe`" x $CloudRIGInstallBaseDir\Apps\razer-surround-driver.exe -o$CloudRIGInstallBaseDir\Apps\razer-surround-driver -y" | Out-Null
    $InstallerManifest = "$CloudRIGInstallBaseDir\Apps\razer-surround-driver\`$TEMP\RazerSurroundInstaller\InstallerManifest.xml"
    $regex = '(?<=<SilentMode>)[^<]*'
    (Get-Content $InstallerManifest) -replace $regex, 'true' | Set-Content $InstallerManifest -Encoding UTF8
    $OriginalLocation = Get-Location
    Set-Location -Path "$CloudRIGInstallBaseDir\Apps\razer-surround-driver\`$TEMP\RazerSurroundInstaller\"
    Start-Process RzUpdateManager.exe
    Set-Location $OriginalLocation
    Set-Service -Name audiosrv -StartupType Automatic
    Write-host "`  - Success!"
}

Function Install-VBCable
{
    Write-Host "  * VB Audio - Cable" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/vb-audio/VBCABLE_Driver_Pack43.zip" -LocalFile "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver.zip" | Out-Null

    Expand-Archive -LiteralPath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver.zip" -DestinationPath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\" | Out-Null
    (Get-AuthenticodeSignature -FilePath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbaudio_cable64_win7.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbcable.cer"
    Import-Certificate -FilePath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher'
    & c:\gcloudrig\downloads\vbcable\
    Start-Process -FilePath "$CloudRIGInstallBaseDir\Apps\VBCABLE_Driver\VBCABLE_Setup_x64.exe" -ArgumentList '-h','-i','-H','-n' -wait
    Write-host "`  - Success!"
}

Function Install-ControllerDriver
{
    if ((gwmi win32_operatingsystem | % caption) -like '*Windows Server 2019*') {
        "Detected Windows Server 2019, downloading Xbox Accessories 1.2 to enable controller support"
        (New-Object System.Net.WebClient).DownloadFile("http://download.microsoft.com/download/6/9/4/69446ACF-E625-4CCF-8F56-58B589934CD3/Xbox360_64Eng.exe", "$CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng.exe")
        Write-Host "In order to use a controller, Microsoft Xbox Accessories are going to be installed..."
        if((Test-Path -Path $CloudRIGInstallBaseDir\Drivers) -eq $true) {} Else {New-Item -Path $CloudRIGInstallBaseDir\Drivers -ItemType Directory | Out-Null}
        cmd.exe /c "`"C:\Program Files\7-Zip\7z.exe`" x $CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng.exe -o$CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng -r -y" | Out-Null
        cmd.exe /c "`"PNPUtil.exe`" /add-driver $CloudRIGInstallBaseDir\Drivers\Xbox360_64Eng\xbox360\setup64\files\driver\win7\xusb21.inf" | Out-Null
        Write-Host "Done installing Microsoft Xbox Accessories"
    }
}

Function Install-NVFBCEnable
{
    Write-Status "Install nvfbcenable.exe"
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/nvidia/NvFBCEnable.zip" -LocalFile "$CloudRIGInstallBaseDir\Apps\NvFBCEnable.zip" | Out-Null
    Expand-Archive -LiteralPath "$CloudRIGInstallBaseDir\Apps\NvFBCEnable.zip" -DestinationPath "$CloudRIGInstallBaseDir\Apps\NvFBCEnable"
}

Function Install-DevCon
{
    Write-Host "  * Downloading Devcon..." -NoNewline
    if((Test-Path -Path "$CloudRIGInstallBaseDir\Devcon") -eq $true) {} Else {New-Item -Path "$CloudRIGInstallBaseDir\Devcon" -ItemType Directory | Out-Null}
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/devcon.exe" -LocalFile "$CloudRIGInstallBaseDir\Devcon\devcon.exe" | Out-Null
    Write-host "`  - Success!"
}

Function Copy-CloudRIGScripts {
    if((Test-Path -Path "$ENV:APPDATA\CloudRIGLoader") -eq $true) {} Else {New-Item -Path "$ENV:APPDATA\CloudRIGLoader" -ItemType Directory | Out-Null}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\clear-proxy.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\clear-proxy.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateClearProxyScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\CreateClearProxyScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\Automatic-Shutdown.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\Automatic-Shutdown.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\CreateAutomaticShutdownScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\GPU-Update.ico) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\GPU-Update.ico" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\CreateOneHourWarningScheduledTask.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\WarningMessage.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\WarningMessage.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\ShowDialog.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\ShowDialog.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\OneHour.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\OneHour.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
    if((Test-Path $ENV:APPDATA\CloudRIGLoader\PrepareInstanceOnStartup.ps1) -eq $true) {} Else {Move-Item -Path "$CloudRIGInstallBaseDir\Resources\PrepareInstanceOnStartup.ps1" -Destination $ENV:APPDATA\CloudRIGLoader}
}

Function Install-AutoShutdownShortcut {
    Write-Output "Create Auto Shutdown Shortcut..."
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\Setup Auto Shutdown.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "ClearProxy shortcut";
    $ShortCut.Save()
}

Function Install-OneHourWarningShortcut {
    Write-Output "Create One Hour Warning..."
    if((Test-Path -Path "$env:USERPROFILE\Desktop\CloudRIG Tools") -eq $true) {} Else {New-Item -Path "$env:USERPROFILE\Desktop\CloudRIG Tools" -ItemType Directory | Out-Null}
    if((Test-Path "$ENV:APPDATA\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1") -eq $true) {} Else {Move-Item -Path $CloudRIGInstallBaseDir\Resources\CreateOneHourWarningScheduledTask.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\CloudRIG Tools\Setup One Hour Warning.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "OneHourWarning shortcut";
    $ShortCut.Save()
}
