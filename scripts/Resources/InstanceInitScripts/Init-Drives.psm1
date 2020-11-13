#
#  CLOUDRIG INSTANCE INIT - Expand all the drives to their maximum
#

Function Expand-AllDrives() {
    Write-Host "Expanding drives partition to their maximum..."
    $volumes = Get-Volume
    For ($counter=0; $counter -lt $volumes.Length; $counter++)
    {
        $volume = $volumes[$counter]
        $volumeLetter = $volume.DriveLetter
        $size = Get-PartitionSupportedSize -DiskNumber $counter -PartitionNumber 1
        [System.Uint64]$currentsize = (Get-Partition -DiskNumber $counter -PartitionNumber 1).Size
        [System.Uint64]$maxpartitionsize = ($size.SizeMax).ToString()
        Write-Host "`  * $volumeLetter -> $currentsize vs $maxpartitionsize"
        if ($($currentsize) -ge $($maxpartitionsize)) {
            Write-Host "` ` `  - Already at its maximum"
        }
        Else
        {
            Write-Host "` `  - Resizing partition to the max..." -NoNewLine
            Resize-Partition -DiskNumber $counter -PartitionNumber 1 -Size $size.SizeMax
            Write-Host "`  - Success"
        }
    }
}
