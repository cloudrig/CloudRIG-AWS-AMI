
function Init-Drives {
    C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeDisks.ps1
}

function Rename-Computer {
    Rename-Computer -NewName "CloudRIG"
}

Init-Drives
Rename-Computer