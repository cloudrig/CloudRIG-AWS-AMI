# CloudRIG - Gaming apps installation module

Import-Module "$PSScriptRoot\Common"

Function Install-CloudProviderSpecificSetup
{
    Write-Output "Doing provider specific customizations for this provider..."

    #Device ID Query
    $gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where (deviceid Like '%PCI\\VEN_10DE%') and (PNPClass = 'Display' or Name = '3D Video Controller')" | Select-Object DeviceID -ExpandProperty DeviceID
    if ($gputype -eq $null)
    {
        Write-Output "No GPU Detected, skipping provider specific tasks"

    }
    Else
    {
        $devicename = $gputype.split('&')[1]
        if ($devicename -eq "DEV_13F2")
        {
            #AWS G3.4xLarge M60
            Write-Output "Tesla M60 Detected"
            Install-AWSSetup
        }

        ElseIF($devicename -eq "DEV_118A")
        {
            #AWS G2.2xLarge K520
            Write-Output "GRID K520 Detected"
            Install-AWSSetup
        }

        ElseIF($devicename -eq "DEV_1BB1")
        {
            #Paperspace P4000
            Write-Output "Quadro P4000 Detected"
            Install-PaperspaceSetup
        }

        Elseif($devicename -eq "DEV_1BB0")
        {
            #Paperspace P5000
            Write-Output "Quadro P5000 Detected"
            Install-PaperspaceSetup
        }

        Elseif($devicename -eq "DEV_15F8")
        {
            #Tesla P100
            Write-Output "Tesla P100 Detected"
            Install-GCESetup
        }

        Elseif($devicename -eq "DEV_1BB3")
        {
            #Tesla P4
            Write-Output "Tesla P4 Detected"
            Install-GCESetup
        }

        Elseif($devicename -eq "DEV_1EB8")
        {
            #Tesla T4 - AWS g4dn.xLarge
            Write-Output "Tesla T4 Detected"
            Install-AWSSetup
        }

        Elseif($devicename -eq "DEV_1430")
        {
            Write-Output "Quadro M2000 Detected"
            Install-AWSSetup
        }

        Else
        {
            Write-Host "The installed GPU is not currently supported, skipping provider specific tasks"
        }
    }
}

Function Install-AWSSetup {
    Write-Host "Running on AWSddddd"

    Write-Host "` * Configure EC2Launch to init drives, change wallpaper, optimize ENA and run startup scripts..." -NoNewLine
    $config = & "C:\Program Files\Amazon\EC2Launch\EC2Launch.exe" get-agent-config --format json | ConvertFrom-Json
    $initVolumes = @{
        "task" = "initializeVolume";
        "inputs" = @{
            "initialize" = "all"
        };
    }
    $optimizeEna = @{"task" = "optimizeEna"};
    $startupScripts = @{
        "task" = "executeProgram";
        "inputs" = [array]@(
            @{
                "frequency" = "always";
                "path" = "powershell.exe";
                "runAs" = "localSystem";
                "arguments" = [array]@("-WindowStyle","hidden","-ExecutionPolicy","Bypass","-File","C:\CloudRIG\Scripts\InstanceInitScripts\Init-Instance.ps1");
            }
        )
    }

    $config.config | %{if($_.stage -eq 'postReady'){$_.tasks += $initVolumes}}
    $config.config | %{if($_.stage -eq 'postReady'){$_.tasks += $optimizeEna}}
    $config.config | %{if($_.stage -eq 'postReady'){$_.tasks += $startupScripts}}
    ConvertTo-Json -InputObject $config -Depth 10 | Out-File -encoding UTF8 "$env:ProgramData/Amazon/EC2Launch/config/agent-config.yml"
    Write-Host "` - Success"
}

Function Install-GCESetup {
    Write-Host "Running on Google Compute Engine"

    Write-Host "` * Remove BGInfo" -NoNewLine
    if((Test-Path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe") -eq $true) {
        Remove-Item -path "C:\Program Files\Google\Compute Engine\tools\BGInfo.exe"
    }
    if((Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk") -eq $true) {
        Remove-Item -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGinfo.lnk"
    }
    Write-Host "` - Success"
}

Function Install-PaperspaceSetup {
    Write-Host "Running on Paperspace"
}
