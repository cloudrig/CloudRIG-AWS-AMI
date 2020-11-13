#
#  INSTANCE INIT SCRIPT
#
#  Note that this script will be executed after each reboot, so it must be resilient
#

$EphemeralStorageDriveLetter = "Z:"

Import-Module -Name "$PSScriptRoot/Init-Drives"
Import-Module -Name "$PSScriptRoot/Init-Games-Libraries"

Expand-AllDrives | Out-File C:\CloudRIG\Logs\intance-init.log
Initialize-GamesLibraries | Out-File C:\CloudRIG\Logs\intance-init.log


