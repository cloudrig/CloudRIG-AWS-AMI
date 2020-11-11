# CloudRIG - Gaming apps installation module

Import-Module "$PSScriptRoot\Common"

Function Install-GamingApp {
    [System.Collections.ArrayList]$script:Jobs = @()
    Write-Host "Installing gaming apps..."
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Parsec (1/10)" -PercentComplete 0
    Install-Parsec
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Rainway (2/10)" -PercentComplete 10
    Install-Rainway
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "NICE-DCV (3/10)" -PercentComplete 20
    Install-NICEDCV
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Steam (4/10)" -PercentComplete 30
    Install-Steam
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Discord (5/10)" -PercentComplete 40
    Install-Discord
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Origin (6/10)" -PercentComplete 50
    Install-Origin
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Battle.net (7/10)" -PercentComplete 60
    Install-Battlenet
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "EpicGames (8/10)" -PercentComplete 70
    Install-EpicGames
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "UPlay (9/10)" -PercentComplete 80
    Install-UPlay
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Waiting for end (10/10)" -PercentComplete 90
    Wait-ForJobs
    Write-Progress -Activity "Installing gaming apps..." -CurrentOperation "Done" -PercentComplete 100
}

Function Wait-ForJobs {
    Write-Progress -Activity "Waiting for jobs end..."
    foreach ($Job in $script:Jobs) {
        $Job.WaitForExit(30000)
    }
}

Function Install-Parsec
{
    Write-Host "  * Parsec" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://builds.parsecgaming.com/package/parsec-windows.exe", "$global:CloudRIGInstallBaseDir\Apps\parsec-windows.exe")
    Start-Process -FilePath "c:\gcloudrig\downloads\parsec-windows.exe" -ArgumentList '/S' -wait
    Write-host "` - Success!"
}

Function Install-Rainway {
    Write-Host "  * Rainway" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://releases.rainway.com/bootstrapper.exe", "$global:CloudRIGInstallBaseDir\Apps\rainway-bootstrapper.exe")
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\rainway-bootstrapper.exe" -ArgumentList '/S' -wait
    Write-host "`  - Success!"
}

Function Install-NICEDCV {
    Write-Host "  * NICE DCV" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://d1uj6qtbmh3dt5.cloudfront.net/2020.1/Servers/nice-dcv-server-x64-Release-2020.1-9012.msi", "$global:CloudRIGInstallBaseDir\Apps\nice-dcv-server-x64-Release.exe")
    Start-Process -FilePath "$global:CloudRIGInstallBaseDir\Apps\nice-dcv-server-x64-Release.exe" -ArgumentList '/quiet','/norestart','/l*v', 'dcv_install_msi.log' -wait
    Write-host "`  - Success!"
}

Function Install-Steam
{
    Write-Host "  * Steam" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe", "$global:CloudRIGInstallBaseDir\Apps\SteamSetup.exe")
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\SteamSetup.exe" -ArgumentList '/S'
    Write-host "`  - Success!"
}

Function Install-Discord
{
    Write-Host "  * Discord" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://discordapp.com/api/download?platform=win", "$global:CloudRIGInstallBaseDir\Apps\DiscordSetup.exe")
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\DiscordSetup.exe"
    Write-host "`  - Success!"
}

Function Install-Origin
{
    Write-Host "  * Origin" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://origin-a.akamaihd.net/Origin-Client-Download/origin/live/OriginThinSetup.exe", "$global:CloudRIGInstallBaseDir\Apps\OriginThinSetup.exe")
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\OriginThinSetup.exe" -ArgumentList '/SILENT'
    Write-host "`  - Success!"
}

Function Install-EpicGames
{
    Write-Host "  * Epic Games launcher" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi", "$global:CloudRIGInstallBaseDir\Apps\EpicGamesLauncherInstaller.msi")
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\EpicGamesLauncherInstaller.msi" -ArgumentList '/qn /norestart'
    Write-host "`  - Success!"
}

Function Install-UPlay
{
    Write-Host "  * uPlay" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UplayInstaller.exe", "$global:CloudRIGInstallBaseDir\Apps\UplayInstaller.exe")
    Start-Process "$global:CloudRIGInstallBaseDir\Apps\UplayInstaller.exe" -ArgumentList '/S'
    Write-host "`  - Success!"
}

Function Install-Battlenet {
    Write-Output "Installing gaming apps..."
    Write-Host "  * Battle.net" -NoNewline
    (New-Object System.Net.WebClient).DownloadFile("https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP", "$global:CloudRIGInstallBaseDir\Apps\Battle.net-Setup.exe")
    Start-Process -FileName "$global:CloudRIGInstallBaseDir\Apps\Battle.net-Setup.exe" -ArgumentList '--lang=english','--bnetdir="c:\Program Files (x86)\Battle.net"'
    Write-host "`  - Success!"
}
