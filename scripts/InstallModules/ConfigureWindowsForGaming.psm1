# CloudRIG - Prepare Windows Server for gaming

Import-Module "$PSScriptRoot\Common"

Function Install-ConfigurationWindowsForGaming
{
    Remove-DefaultShortcuts
    Enable-Audio
    Optimize-ForGamingPerformance
    Optimize-DesktopExperience
    Register-Scripts
    Enable-ForceCloseApps
}

Function Remove-DefaultShortcuts
{
    Write-Host "Removing existing shotcuts on the Desktop..."
    Get-ChildItem -Path "$env:USERPROFILE\Desktop\" *.lnk | foreach { Remove-Item -Path $_.FullName }
    Get-ChildItem -Path "$env:USERPROFILE\Desktop\" *.website | foreach { Remove-Item -Path $_.FullName }
}

Function Enable-Audio
{
    # Start audio service
    Set-Service Audiosrv -startuptype "automatic"
    Start-Service Audiosrv

    # Enable microphone
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone -Name "Value" -Value "Allow"
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone -Name "Value" -Value "Allow"
}

# Copied from https://github.com/putty182/gcloudrig/
Function Optimize-ForGamingPerformance
{
    Write-Status "Disabling things that slow down the system unexpectedly..."

    # turn off ie security
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

    # priority to programs, not background
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38

    # explorer set to performance
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

    # disable explorer features
    $UserKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    Set-ItemProperty $UserKey "NoLowDiskSpaceChecks" 1
    Set-ItemProperty $UserKey "LinkResolveIgnoreLinkInfo" 1
    Set-ItemProperty $UserKey "NoResolveSearch" 1
    Set-ItemProperty $UserKey "NoResolveTrack" 1
    Set-ItemProperty $UserKey "NoInternetOpenWith" 1

    # Turn off Shutdown Event Tracker
    Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\reliability" ShutdownReasonOn 0

    # Turn off Windows Error Reporting
    Set-ItemProperty "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" DontShowUI 1

    # disable crash dump
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "CrashDumpEnabled" -Value 0

    # disable some more scheduled tasks
    Disable-ScheduledTask -TaskName 'ServerManager' -TaskPath '\Microsoft\Windows\Server Manager'
    Disable-ScheduledTask -TaskName 'ScheduledDefrag' -TaskPath '\Microsoft\Windows\Defrag'
    Disable-ScheduledTask -TaskName 'ProactiveScan' -TaskPath '\Microsoft\Windows\Chkdsk'
    Disable-ScheduledTask -TaskName 'Scheduled' -TaskPath '\Microsoft\Windows\Diagnosis'
    Disable-ScheduledTask -TaskName 'SilentCleanup' -TaskPath '\Microsoft\Windows\DiskCleanup'
    Disable-ScheduledTask -TaskName 'WinSAT' -TaskPath '\Microsoft\Windows\Maintenance'
    Disable-ScheduledTask -TaskName 'StartComponentCleanup' -TaskPath '\Microsoft\Windows\Servicing'

    # disable unnecessary services
    $services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service
    "LanmanServer"                             # File/Printer sharing
    "Spooler"                                  # Printing stuff
    "RemoteAccess"                             # Routing and Remote Access
    )
    foreach ($service in $services) {
        Set-Service $service -startuptype "disabled"
        Stop-Service $service -force
    }
    Write-Status "  done."
}

# Copied from https://github.com/putty182/gcloudrig/
Function Optimize-DesktopExperience
{
    Write-Status "Configuring Desktop..."

    # show file extensions, hidden items and disable item checkboxes
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty $key HideFileExt 0
    Set-ItemProperty $key HideDrivesWithNoMedia 0
    Set-ItemProperty $key Hidden 1
    Set-ItemProperty $key AutoCheckSelect 0

    # weird accessibility stuff
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"

    # disable telemetry
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" -Value 0

    # don't combine taskbar buttons and no tray hiding stuff
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarGlomLevel -Value 2
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name EnableAutoTray -Value 0

    # hide the touchbar button on the systray
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name PenWorkspaceButtonDesiredVisibility -Value 0

    # Stop Server Manager and Startup Tasks from appearing in console
    Set-ItemProperty "HKLM:\Software\Microsoft\ServerManager" DoNotOpenServerManagerAtLogon 1
    Set-ItemProperty "HKLM:\Software\Microsoft\ServerManager" CheckUnattendLaunchSetting 0
    Set-ItemProperty "HKLM:\Software\Microsoft\ServerManager\Oobe" DoNotOpenInitialConfigurationTasksAtLogon 1

    # Remove GCE BGInfo background setter
    Remove-Item -Force (Join-Path (Get-SpecialFolder CommonStartup) "BGInfo.lnk")

    # Don't prompt for network location
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

    # Enable Enhanced Pointer Precision
    Set-Itemproperty -Path 'HKCU:\Control Panel\Mouse' -Name MouseSpeed -Value 1 | Out-Null

    # Disabling Shutdown Option in Start Menu
    # Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" NoClose 1
    # Disabling Logout Option in Start Menu
    # Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" StartMenuLogOff 1

    Write-Output "Setting Time to Automatic..."
    Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name Type -Value NTP | Out-Null
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value 00000003 | Out-Null
}

Function Register-Scripts
{
    if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory | Out-Null}
    if((Test-Path -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown) -eq $true) {} Else {New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory | Out-Null}
    if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\psscripts.ini) -eq $true) {} Else {Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts}


    # Update GPO if needed
    If (Test-Path ("C:\Windows\system32\GroupPolicy" + "\gpt.ini"))
    {
        $querygpt = Get-content C:\Windows\System32\GroupPolicy\gpt.ini
        $matchgpt = $querygpt -match '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}'
        If ($matchgpt -contains "*0000F87571E3*" -eq $false)
        {
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
            (Get-Content C:\Windows\System32\GroupPolicy\gpt.ini) -replace "Version=$i", "Version=$n" | Set-Content C:\Windows\System32\GroupPolicy\gpt.ini
        }
    }
    Else
    {
        Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\gpt.ini -Destination C:\Windows\system32\GroupPolicy -Force | Out-Null
    }

    # Register a shutdown script that
    if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\psscripts.ini) -eq $true) {} Else {Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts}
    if((Test-Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown\NetworkRestore.ps1) -eq $true) {} Else {Move-Item -Path $global:CloudRIGInstallBaseDir\Resources\NetworkRestore.ps1 -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown}
    regedit /s $global:CloudRIGInstallBaseDir\Resources\NetworkRestore.reg

    regedit /s $global:CloudRIGInstallBaseDir\Resources\ForceCloseShutDown.reg

    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
}

Function Enable-ForceCloseApps
{
    if (((Get-Item -Path "HKCU:\Control Panel\Desktop").GetValue("AutoEndTasks") -ne $null) -eq $true) {
        Set-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
        Write-Host "Removed Startup Item from Razer Synapse"
    }
    Else {
        New-ItemProperty -path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1"
    }
}
