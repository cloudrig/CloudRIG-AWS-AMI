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
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100 VW    (Tesla P100 Virtual Workstation)
                    Google P4  VW    (Tesla P4 Virtual Workstation)
                    Google T4  VW    (Tesla T4 Virtual Workstation)
    
"                                         
Write-Output "Setting up Environment"
$path = [Environment]::GetFolderPath("Desktop")
if((Test-Path -Path $path\CloudRIGTemp )-eq $true){} Else {New-Item -Path $path\CloudRIGTemp -ItemType directory | Out-Null}
Unblock-File -Path .\*
copy-Item .\* -Destination $path\CloudRIGTemp\ -Recurse | Out-Null
#lil nap
Start-Sleep -s 1
#Unblocking all script files
Write-Output "Unblocking files just in case"
Get-ChildItem -Path $path\CloudRIGTemp -Recurse | Unblock-File

Write-Output "Starting the installation script..."
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Verb = 'RunAs'
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "-file $path\CloudRIGTemp\Installer.ps1 "
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start()
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host "stderr: $stderr"
Write-Host "stdout: $stdout"
Write-Host "exit code: " + $p.ExitCode