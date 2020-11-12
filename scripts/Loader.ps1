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
                    AWS G4dn.xLarge   (Telsa T4)
                    AWS G2.2xLarge    (GRID K520)
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100 VW    (Tesla P100 Virtual Workstation)
                    Google P4  VW     (Tesla P4 Virtual Workstation)
                    Google T4  VW     (Tesla T4 Virtual Workstation)
    
"                                         
Write-Output "Setting up Environment"
Set-Variable -Name CloudRIGInstallBaseDir -Value 'C:\CloudRIGInstall\' -Scope Global

Write-Output "Creating $global:CloudRIGInstallBaseDir..."

if((Test-Path -Path "$global:CloudRIGInstallBaseDir" )-eq $true){} Else {New-Item -Path "$global:CloudRIGInstallBaseDir" -ItemType directory | Out-Null}


Write-Output "Starting the installation script..."
Import-Module -Name "$PSScriptRoot/Installer.psm1"
Install-EntryPoint
