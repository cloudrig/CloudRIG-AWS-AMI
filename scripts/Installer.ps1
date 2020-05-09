$path = [Environment]::GetFolderPath("Desktop")
$currentusersid = Get-LocalUser "$env:USERNAME" | Select-Object SID | ft -HideTableHeaders | Out-String | ForEach-Object { $_.Trim() }

#Creating Folders and moving script files into System directories
function setupEnvironment {
if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory | Out-Null}
if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory | Out-Null}
if((Test-Path -Path $env:USERPROFILE\AppData\Roaming\CloudRIGLoader) -eq $true) {} Else {New-Item -Path $env:USERPROFILE\AppData\Roaming\CloudRIGLoader -ItemType directory | Out-Null}
if((Test-Path -Path "$path\Auto Login") -eq $true) {} Else {New-Item -path "$path\Auto Login" -ItemType Directory | Out-Null}
if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\psscripts.ini) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts}
if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown\NetworkRestore.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\NetworkRestore.ps1 -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\clear-proxy.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\clear-proxy.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateClearProxyScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\CreateClearProxyScheduledTask.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\Automatic-Shutdown.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\Automatic-Shutdown.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\CreateAutomaticShutdownScheduledTask.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\GPU-Update.ico) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\GPU-Update.ico -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\CreateOneHourWarningScheduledTask.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\WarningMessage.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\WarningMessage.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\ShowDialog.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\ShowDialog.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
if((Test-Path $ENV:APPDATA\CloudRIGLoader\OneHour.ps1) -eq $true) {} Else {Move-Item -Path $path\CloudRIGTemp\Resources\OneHour.ps1 -Destination $ENV:APPDATA\CloudRIGLoader}
}



#Modifies Local Group Policy to enable Shutdown scrips items
function add-gpo-modifications {
$querygpt = Get-content C:\Windows\System32\GroupPolicy\gpt.ini
$matchgpt = $querygpt -match '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}'
if ($matchgpt -contains "*0000F87571E3*" -eq $false) {
write-output "Adding modifications to GPT.ini"
$gptstring = get-content C:\Windows\System32\GroupPolicy\gpt.ini
$gpoversion = $gptstring -match "Version"
$GPO = $gptstring -match "gPCMachineExtensionNames"
$add = '[{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}]'
$replace = "$GPO" + "$add"
(Get-Content "C:\Windows\System32\GroupPolicy\gpt.ini").Replace("$GPO","$replace") | Set-Content "C:\Windows\System32\GroupPolicy\gpt.ini"
[int]$i = $gpoversion.trim("Version=") 
[int]$n = $gpoversion.trim("Version=")
$n +=2
(Get-Content C:\Windows\System32\GroupPolicy\gpt.ini) -replace "Version=$i", "Version=$n" | Set-Content C:\Windows\System32\GroupPolicy\gpt.ini}
else{write-output "Not Required"}
}

#Adds Premade Group Policu Item if existing configuration doesn't exist
function addRegItems{if (Test-Path ("C:\Windows\system32\GroupPolicy" + "\gpt.ini")) 
{add-gpo-modifications}
Else
{Move-Item -Path $path\CloudRIGTemp\Resources\gpt.ini -Destination C:\Windows\system32\GroupPolicy -Force | Out-Null}
regedit /s $path\CloudRIGTemp\Resources\NetworkRestore.reg
regedit /s $path\CloudRIGTemp\Resources\ForceCloseShutDown.reg
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
}

function Test-RegistryValue {
# https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
param (

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Path,

[parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Value
)

try {

Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 return $true
 }

catch {

return $false

}

}

function remove-existing-shortcuts-desktop {
    Write-Host "Removing existing shotcuts on the Desktop..."
    Get-ChildItem -Path "$env:USERPROFILE\Desktop\" *.lnk | foreach { Remove-Item -Path $_.FullName }
}

#Create CloudRIGTemp folder in C Drive
function create-directories {
Write-Output "Creating Directories in C:\ Drive"
if((Test-Path -Path C:\CloudRIGTemp) -eq $true) {} Else {New-Item -Path C:\CloudRIGTemp -ItemType directory | Out-Null}
if((Test-Path -Path C:\CloudRIGTemp\Apps) -eq $true) {} Else {New-Item -Path C:\CloudRIGTemp\Apps -ItemType directory | Out-Null}
if((Test-Path -Path C:\CloudRIGTemp\DirectX) -eq $true) {} Else {New-Item -Path C:\CloudRIGTemp\DirectX -ItemType directory | Out-Null}
if((Test-Path -Path C:\CloudRIGTemp\Drivers) -eq $true) {} Else {New-Item -Path C:\CloudRIGTemp\Drivers -ItemType Directory | Out-Null}
if((Test-Path -Path C:\CloudRIGTemp\Devcon) -eq $true) {} Else {New-Item -Path C:\CloudRIGTemp\Devcon -ItemType Directory | Out-Null}
}

#disable IE security
function disable-iesecurity {
Write-Output "Enabling Web Browsing on IE (Disabling IE Security)"
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force
}

#download-files-S3
function download-softwares-installers {
    Write-Output "Downloading tools..."
    Write-Host "  * DirectX" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe", "C:\CloudRIGTemp\Apps\directx_Jun2010_redist.exe")
    Write-host "`  - Success!"
    Write-Host "  * GPU Update tool" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/cloudrig/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$env:APPDATA\CloudRIGLoader\GPU Updater Tool.ps1")
    Write-host "`  - Success!"
    Write-Host "  * Chrome" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi", "C:\CloudRIGTemp\Apps\googlechromestandaloneenterprise64.msi")
    Write-host "`  - Success!"
    Write-Host "  * Rainway" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://releases.rainway.com/bootstrapper.exe", "C:\CloudRIGTemp\Apps\rainway-bootstrapper.exe")
    Write-host "`  - Success!"
    Write-Host "  * 7Zip"
    $url = Invoke-WebRequest -Uri https://www.7-zip.org/download.html
    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/$($($($url.Links | Where-Object outertext -Like "Download")[1]).OuterHTML.split('"')[1])" ,"C:\CloudRIGTemp\Apps\7zip.exe")
    Write-host "`  - Success!"
    Write-Host "  * Devcon" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/devcon.exe" -LocalFile "C:\CloudRIGTemp\Devcon\devcon.exe" | Out-Null
    Write-host "`  - Success!"
    Write-Host "  * VC Redist 2010" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2010_x86.exe" -LocalFile "C:\CloudRIGTemp\Apps\vc_redist_2010_x86.exe" | Out-Null
    Write-host "`  - Success!"
    Write-Host "  * VC Redist 2015" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x86.exe" -LocalFile "C:\CloudRIGTemp\Apps\vc_redist_2015_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2015_x64.exe" -LocalFile "C:\CloudRIGTemp\Apps\vc_redist_2015_x64.exe"
    Write-host "`  - Success!"
    Write-Host "  * VC Redist 2017" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x86.exe" -LocalFile "C:\CloudRIGTemp\Apps\vc_redist_2017_x86.exe" | Out-Null
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/microsoft/vc_redist_2017_x64.exe" -LocalFile "C:\CloudRIGTemp\Apps\vc_redist_2017_x64.exe" | Out-Null
    Write-host "`  - Success!"
    Write-Host "  * SetDefaultBrowser" -NoNewline
    Copy-S3Object -BucketName "cloudrig-amifactory" -Key "vendor/kolbicz/SetDefaultBrowser.exe" -LocalFile "C:\CloudRIGTemp\Apps\SetDefaultBrowser.exe" | Out-Null
    Write-host "`  - Success!"
}


#install-base-files-silently
function install-softwares {
    Write-Output "Installing tools..."

    Write-Host "  * Chrome" -NoNewline
    start-process -filepath "C:\Windows\System32\msiexec.exe" -ArgumentList '/qn /i "C:\CloudRIGTemp\Apps\googlechromestandaloneenterprise64.msi"' -Wait
    set-default-browser
    Write-host "`  - Success!"

    Write-Host "  * Direct X" -NoNewline
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\directx_jun2010_redist.exe" -ArgumentList '/T:C:\CloudRIGTemp\DirectX /Q'-wait
    Start-Process -FilePath "C:\CloudRIGTemp\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -wait
    Remove-Item -Path C:\CloudRIGTemp\DirectX -force -Recurse
    Write-host "`  - Success!"

    Write-Host "  * VC Redist" -NoNewline
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\vc_redist_2010_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\vc_redist_2015_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\vc_redist_2015_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\vc_redist_2017_x86.exe" -ArgumentList '/install /passive /norestart' -wait
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\vc_redist_2017_x64.exe" -ArgumentList '/install /passive /norestart' -wait
    Write-host "`  - Success!"

    Write-Host "  * Rainway" -NoNewline
    Start-Process -FilePath "C:\CloudRIGTemp\Apps\rainway-bootstrapper.exe" -ArgumentList '/S' -wait
    Write-host "`  - Success!"

    Write-Host "  * 7zip" -NoNewline
    Start-Process C:\CloudRIGTemp\Apps\7zip.exe -ArgumentList '/S /D="C:\Program Files\7-Zip"' -Wait
    Write-host "`  - Success!"

    Write-Host "  * Windows Direct Play" -NoNewline
    Install-WindowsFeature Direct-Play | Out-Null
    Write-host "`  - Success!"

    Write-Host "  * Windows Net Framework" -NoNewline
    Install-WindowsFeature Net-Framework-Core | Out-Null
    Write-host "`  - Success!"


}

function set-default-browser {
    Start-Process "C:\CloudRIGTemp\Apps\SetDefaultBrowser.exe" -ArgumentList 'HKLM "Google Chrome"' -Wait
    $Target = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
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
}

#set update policy
function set-update-policy {
    Write-Output "Disabling Windows Update"
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'DoNotConnectToWindowsUpdateInternetLocations') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value "1" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value "1" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'UpdateServiceURLAlternative') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceURLAlternative" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceURLAlternative" -Value "http://intentionally.disabled" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'WUServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" -Value "http://intentionally.disabled" | Out-Null}
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -value 'WUSatusServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUSatusServer" -Value "http://intentionally.disabled" | Out-Null} else {new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUSatusServer" -Value "http://intentionally.disabled" | Out-Null}
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "AUOptions" -Value 1 | Out-Null
    if((Test-RegistryValue -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -value 'UseWUServer') -eq $true) {Set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" -Value 1 | Out-Null} else {new-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" -Value 1 | Out-Null}
}

#set automatic time and timezone
function set-time {
    Write-Output "Setting Time to Automatic"
    Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name Type -Value NTP | Out-Null
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value 00000003 | Out-Null
}

#disable new network window
function disable-network-window {
Write-Output "Disabling New Network Window"
    if((Test-RegistryValue -path HKLM:\SYSTEM\CurrentControlSet\Control\Network -Value NewNetworkWindowOff)-eq $true) {

    } Else {
        new-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Control\Network -name "NewNetworkWindowOff" | Out-Null
    }
}

#Enable Pointer Precision 
function enhance-pointer-precision {
    Write-Output "Enabling Enhanced Pointer Precision"
    Set-Itemproperty -Path 'HKCU:\Control Panel\Mouse' -Name MouseSpeed -Value 1 | Out-Null
}

#enable Mouse Keys
function enable-mousekeys {
    Write-Output "Enabling Mouse Keys"
    Set-Itemproperty -Path 'HKCU:\Control Panel\Accessibility\MouseKeys' -Name Flags -Value 63 | Out-Null
}

#disable shutdown start menu
function remove-shutdown {
    Write-Output "Disabling Shutdown Option in Start Menu"
    New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoClose -Value 1 | Out-Null
}

#Sets all applications to force close on shutdown
function force-close-apps {
    if (((Get-Item -Path "HKCU:\Control Panel\Desktop").GetValue("AutoEndTasks") -ne $null) -eq $true) {
        Set-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
        Write-Host "Removed Startup Item from Razer Synapse"
    }
    Else {
        New-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
    }
}

#show hidden items
function show-hidden-items {
    Write-Output "Showing Hidden Files in Explorer"
    set-itemproperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1 | Out-Null
}

#show file extensions
function show-file-extensions {
    Write-Output "Showing File Extensions"
    Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name HideFileExt -Value 0 | Out-Null
}

#disable logout start menu
function disable-logout {
    Write-Output "Disabling Logout"
    if((Test-RegistryValue -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Value StartMenuLogOff )-eq $true) {Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1 | Out-Null} Else {New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1 | Out-Null}
}

#disable lock start menu
function disable-lock {
    Write-Output "Disable Lock"
    if((Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System) -eq $true) {} Else {New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies -Name Software | Out-Null}
    if((Test-RegistryValue -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Value DisableLockWorkstation) -eq $true) {Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableLockWorkstation -Value 1 | Out-Null } Else {New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableLockWorkstation -Value 1 | Out-Null}
}

#set wallpaper
function set-wallpaper {
    Write-Output "Setting WallPaper"
    #if((Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System) -eq $true) {} Else {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null}
    #if((Test-RegistryValue -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -value Wallpaper) -eq $true) {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -value "C:\CloudRIGTemp\parsec+desktop.png" | Out-Null} Else {New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -PropertyType String -value "C:\CloudRIGTemp\parsec+desktop.png" | Out-Null}
    #if((Test-RegistryValue -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -value WallpaperStyle) -eq $true) {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -value 2 | Out-Null} Else {New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -PropertyType String -value 2 | Out-Null}
    #Stop-Process -ProcessName explorer
}

#disable recent start menu items
function disable-recent-start-menu {
    New-Item -path HKLM:\SOFTWARE\Policies\Microsoft\Windows -name Explorer
    New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -PropertyType DWORD -Name HideRecentlyAddedApps -Value 1
}

#enable auto login - remove user password
function autoLogin { Write-Host "This cloud machine needs to be set to automatically login - please use the Setup Auto Login shortcut + Instructions on the desktop to set this up when the script is finished" -ForegroundColor red
    (New-Object System.Net.WebClient).DownloadFile("https://download.sysinternals.com/files/AutoLogon.zip", "$env:APPDATA\CloudRIGLoader\Autologon.zip")
    Expand-Archive "$env:APPDATA\CloudRIGLoader\Autologon.zip" -DestinationPath "$env:APPDATA\CloudRIGLoader" -Force
    $output = "
    This application was provided by Mark Rusinovish from System Internals",
    "https://docs.microsoft.com/en-us/sysinternals/downloads/autologon",
    "",
    "What this application does:  Enables your server to automatically login, so you can log into Rainway straight away.",
    "When to use it: The first time you setup your server, or when you change your servers password.",
    "",
    "Instructions",
    "Accept the EULA and enter the following details",
    "Username: $env:username",
    "Domain: $env:Computername",
    "Password: The password you got from Azure/AWS/Google that you use to log into RDP"
    $output | Out-File "$path\Auto Login\Auto Login Instructions.txt"

    autoLoginShortCut
}

#Creates Shortcut to Autologon.exe
function autoLoginShortCut {
    Write-Output "Create Auto Login Shortcut"
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$path\Auto Login\Setup Auto Logon.lnk")
    $ShortCut.TargetPath="$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\Autologon.exe"
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "Setup AutoLogon Shortcut";
    $ShortCut.Save()
}

#createshortcut
function Create-ClearProxy-Shortcut{
    Write-Output "Create ClearProxy shortcut"
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\Auto Recover GPU.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateClearProxyScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "ClearProxy shortcut";
    $ShortCut.Save()
}

#createshortcut
function Create-AutoShutdown-Shortcut{
    Write-Output "Create Auto Shutdown Shortcut"
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\Setup Auto Shutdown.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateAutomaticShutdownScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "ClearProxy shortcut";
    $ShortCut.Save()
}

#createshortcut
function Create-One-Hour-Warning-Shortcut{
    Write-Output "Create One Hour Warning"
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$env:USERPROFILE\Desktop\Setup One Hour Warning.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\CreateOneHourWarningScheduledTask.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "OneHourWarning shortcut";
    $ShortCut.Save()
}

#Disables Server Manager opening on Startup
function disable-server-manager {
Write-Output "Disable Auto Opening Server Manager"
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null
}

#AWS Clean up Desktop Items
function clean-aws {
remove-item -path "$path\EC2 Feedback.Website"
Remove-Item -Path "$path\EC2 Microsoft Windows Guide.website"
}


Function ExtractRazerAudio {
    #Move extracts Razer Surround Files into correct location
    Write-Host "Moving Razer Surround files to the correct location"
    cmd.exe /c '"C:\Program Files\7-Zip\7z.exe" x C:\CloudRIGTemp\Apps\razer-surround-driver.exe -oC:\CloudRIGTemp\Apps\razer-surround-driver -y' | Out-Null
    }

    Function ModidifyManifest {
    #modifys the installer manifest to run without interraction
    $InstallerManifest = 'C:\CloudRIGTemp\Apps\razer-surround-driver\$TEMP\RazerSurroundInstaller\InstallerManifest.xml'
    $regex = '(?<=<SilentMode>)[^<]*'
    (Get-Content $InstallerManifest) -replace $regex, 'true' | Set-Content $InstallerManifest -Encoding UTF8
}

#AWS Specific tweaks
function aws-setup {
    #clean-aws
    Write-Output "Installing VNC, and installing audio driver"
    (New-Object System.Net.WebClient).DownloadFile($(((Invoke-WebRequest -Uri https://www.tightvnc.com/download.php -UseBasicParsing).Links.OuterHTML -like "*Installer for Windows (64-bit)*").split('"')[1].split('"')[0]), "C:\CloudRIGTemp\Apps\tightvnc.msi")
    (New-Object System.Net.WebClient).DownloadFile("http://rzr.to/surround-pc-download", "C:\CloudRIGTemp\Apps\razer-surround-driver.exe")
    start-process msiexec.exe -ArgumentList '/i C:\CloudRIGTemp\Apps\TightVNC.msi /quiet /norestart ADDLOCAL=Server SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=4ubg9sde SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=4ubg9sde' -Wait
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $env:USERNAME | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "" | Out-Null
    if((Test-RegistryValue -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value AutoAdminLogin)-eq $true){Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null} Else {New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null}
    Write-Host "Installing Razer Surround - it's the Audio Driver - you DON'T need to sign into Razer Synapse" -ForegroundColor Red
    ExtractRazerAudio
    ModidifyManifest
    $OriginalLocation = Get-Location
    Set-Location -Path 'C:\CloudRIGTemp\Apps\razer-surround-driver\$TEMP\RazerSurroundInstaller\'
    Write-Output "The Audio Driver, Razer Surround is now installing"
    Start-Process RzUpdateManager.exe
    Set-Location $OriginalLocation
    Set-Service -Name audiosrv -StartupType Automatic
    Write-Output "VNC has been installed on this computer using Port 5900 and Password 4ubg9sde"

    Write-Output "Initializing the ephemeral drives..."
    C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeDisks.ps1
}

#Creates shortcut for the GPU Updater tool
function gpu-update-shortcut {
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/cloudrig/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1")
    Unblock-File -Path "$ENV:Appdata\CloudRIGLoader\GPU Updater Tool.ps1"
    Write-Output "GPU-Update-Shortcut"
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut("$path\GPU Updater.lnk")
    $ShortCut.TargetPath="powershell.exe"
    $ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1"'
    $ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader";
    $ShortCut.IconLocation = "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU-Update.ico, 0";
    $ShortCut.WindowStyle = 0;
    $ShortCut.Description = "GPU Updater shortcut";
    $ShortCut.Save()
}

#Provider specific driver install and setup
Function provider-specific {
    Write-Output "Doing provider specific customizations"
    #Device ID Query
    $gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where (deviceid Like '%PCI\\VEN_10DE%') and (PNPClass = 'Display' or Name = '3D Video Controller')" | Select-Object DeviceID -ExpandProperty DeviceID
    if ($gputype -eq $null) {
        Write-Output "No GPU Detected, skipping provider specific tasks"

    } Else {
        $devicename = $gputype.split('&')[1]
        if($devicename -eq "DEV_13F2") {
            #AWS G3.4xLarge M60
            Write-Output "Tesla M60 Detected"
            autologin
            aws-setup
        }

        ElseIF($devicename -eq "DEV_118A") {
            #AWS G2.2xLarge K520
            autologin
            aws-setup
            Write-Output "GRID K520 Detected"
        }

        ElseIF($devicename -eq "DEV_1BB1") {
            #Paperspace P4000
            Write-Output "Quadro P4000 Detected"
        }

        Elseif($devicename -eq "DEV_1BB0") {
            #Paperspace P5000
            Write-Output "Quadro P5000 Detected"
        }

        Elseif($devicename -eq "DEV_15F8") {
            #Tesla P100
            Write-Output "Tesla P100 Detected"
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            autologin
            aws-setup
        }

        Elseif($devicename -eq "DEV_1BB3") {
            #Tesla P4
            Write-Output "Tesla P4 Detected"
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            autologin
            aws-setup
        }

        Elseif($devicename -eq "DEV_1EB8") {
            #Tesla T4
            Write-Output "Tesla T4 Detected"
            if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {remove-item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"} Else {}
            if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"} Else {}
            autologin
            aws-setup
        }

        Elseif($devicename -eq "DEV_1430") {
            #Quadro M2000
            Write-Output "Quadro M2000 Detected"
            autologin
            aws-setup
        }

        Else {
            write-host "The installed GPU is not currently supported, skipping provider specific tasks"
        }
    }
}

#Checks for Server 2019 and asks user to install Windows Xbox Accessories in order to let their controller work
Function Server2019Controller {
    if ((gwmi win32_operatingsystem | % caption) -like '*Windows Server 2019*') {
        "Detected Windows Server 2019, downloading Xbox Accessories 1.2 to enable controller support"
        (New-Object System.Net.WebClient).DownloadFile("http://download.microsoft.com/download/6/9/4/69446ACF-E625-4CCF-8F56-58B589934CD3/Xbox360_64Eng.exe", "C:\CloudRIGTemp\Drivers\Xbox360_64Eng.exe")
        Write-Host "In order to use a controller, Microsoft Xbox Accessories are going to be installed..." -ForegroundColor Red
        cmd.exe /c '"C:\Program Files\7-Zip\7z.exe" x C:\CloudRIGTemp\Drivers\Xbox360_64Eng.exe -oC:\CloudRIGTemp\Drivers\Xbox360_64Eng -r -y' | Out-Null
        cmd.exe /c '"PNPUtil.exe" /add-driver C:\CloudRIGTemp\Drivers\Xbox360_64Eng\xbox360\setup64\files\driver\win7\xusb21.inf'
    }
}

Function CreateFireWallRule {
#Creates Parsec Firewall Rule in Windows Firewall
Write-host "Creating Rainway Firewall Rule"
# New-NetFirewallRule -DisplayName "Rainway" -Direction Inbound -Program "C:\Program Files\Rainway\Parsecd.exe" -Profile Private,Public -Action Allow -Enabled True | Out-Null
}

function Install-Gaming-Apps {
    Write-Output "Downloading gaming apps..."
    Write-Host "  * Steam" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe", "C:\CloudRIGTemp\Apps\SteamSetup.exe")
    Write-host "`  - Success!"
    Write-Host "  * Discord" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://discordapp.com/api/download?platform=win", "C:\CloudRIGTemp\Apps\DiscordSetup.exe")
    Write-host "`  - Success!"
    Write-Host "  * Origin" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://origin-a.akamaihd.net/Origin-Client-Download/origin/live/OriginThinSetup.exe", "C:\CloudRIGTemp\Apps\OriginThinSetup.exe")
    Write-host "`  - Success!"
    Write-Host "  * Battle.net" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP", "C:\CloudRIGTemp\Apps\Battle.net-Setup.exe")
    Write-host "`  - Success!"
    Write-Host "  * Epic Games launcher" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi", "C:\CloudRIGTemp\Apps\EpicGamesLauncherInstaller.msi")
    Write-host "`  - Success!"
    Write-Host "  * uPlay" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UplayInstaller.exe", "C:\CloudRIGTemp\Apps\UplayInstaller.exe")
    Write-host "`  - Success!"


    Write-Output "Installing gaming apps..."
    Write-Host "  * Steam" -NoNewline
    Start-Process "C:\CloudRIGTemp\Apps\SteamSetup.exe" -ArgumentList '/S'
    Write-host "`  - Success!"
    Write-Host "  * Discord" -NoNewline
    Start-Process "C:\CloudRIGTemp\Apps\DiscordSetup.exe"
    Write-host "`  - Success!"
    Write-Host "  * Origin" -NoNewline
    Start-Process "C:\CloudRIGTemp\Apps\OriginThinSetup.exe" -ArgumentList '/SILENT'
    Write-host "`  - Success!"
    # No silent install available :/
    #Write-Host "Installing Battle.net" -NoNewline
    #Start-Process "C:\CloudRIGTemp\Apps\Battle.net-Setup.exe" -ArgumentList '/S /Silent /SILENT /q /QUIET'
    #Write-host "`  - Success!"
    Write-Host "  * Epic Games Launcher" -NoNewline
    Start-Process "C:\CloudRIGTemp\Apps\EpicGamesLauncherInstaller.msi" -ArgumentList '/qn /norestart'
    Write-host "`  - Success!"
    Write-Host "  * uPlay" -NoNewline
    Start-Process "C:\CloudRIGTemp\Apps\UplayInstaller.exe" -ArgumentList '/S'
    Write-host "`  - Success!"

    Write-host "Sleeping 20s to let the installer finish their work"
    Start-Sleep -Seconds 20
}

#Disable Devices
function disable-devices {
    Write-Output "Disabling devices not required"
    Start-Process -FilePath "C:\CloudRIGTemp\Devcon\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'
    Get-PnpDevice| where {$_.friendlyname -like "Generic Non-PNP Monitor" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Get-PnpDevice| where {$_.friendlyname -like "Microsoft Basic Display Adapter" -and $_.status -eq "OK"} | Disable-PnpDevice -confirm:$false
    Start-Process -FilePath "C:\CloudRIGTemp\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8*"'
}

function update-gpu {
    # Execute the GPU Updater in silent mode
    cd $env:USERPROFILE\AppData\Roaming\CloudRIGLoader
    & "$env:USERPROFILE\AppData\Roaming\CloudRIGLoader\GPU Updater Tool.ps1" -Confirm false -DoNotReboot true
}

#Cleanup
function clean-up {
    Write-Output "Cleaning up!"
    Remove-Item -Path C:\CloudRIGTemp\Drivers -force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path $path\CloudRIGTemp -force -Recurse -ErrorAction SilentlyContinue
}

#cleanup recent files
function clean-up-recent {
    Write-Output "Removing recent files"
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force | Out-Null
}

Write-Host -foregroundcolor red "
                         ~CloudRIG Cloud Setup Script~

                    This script sets up your cloud computer
                    with a bunch of settings and drivers
                    to make your life easier.  
                    
                    It's provided with no warranty, 
                    so use it at your own risk.
                    
                    Check out the Readme.txt for more
                    information.

                    This tool supports:

                    OS:
                    Server 2016
                    Server 2019
                    
                    CLOUD SKU:
                    AWS G3.4xLarge    (Tesla M60)
                    AWS G2.2xLarge    (GRID K520)
                    AWS G4dn.xLarge   (Tesla T4 with vGaming driver)
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100 VW    (Tesla P100 Virtual Workstation)
                    Google P4  VW    (Tesla P4 Virtual Workstation)
                    Google T4  VW    (Tesla T4 Virtual Workstation)

"   
setupEnvironment
addRegItems
create-directories
disable-iesecurity
remove-existing-shortcuts-desktop
download-softwares-installers
install-softwares
set-update-policy 
disable-network-window
disable-logout
disable-lock
show-hidden-items
show-file-extensions
enhance-pointer-precision
enable-mousekeys
set-time
disable-server-manager
Install-Gaming-Apps
Start-Sleep -s 5
Server2019Controller
gpu-update-shortcut
disable-devices
set-wallpaper
Create-ClearProxy-Shortcut
Create-AutoShutdown-Shortcut
Create-One-Hour-Warning-Shortcut
clean-up
clean-up-recent
force-close-apps
provider-specific
update-gpu