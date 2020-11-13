

Function Initialize-GamesLibraries {
    Initialize-SteamLibraryOnAllDrives
}

Function Initialize-SteamLibraryOnAllDrives {
    $SteamConfigurationFilePath = "C:\Program Files (x86)\Steam\config\config.vdf"
    $SteamLibraryConfigurationFilePath = "C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"

    # If Steam is installed
    If((Test-Path -Path "$SteamLibraryConfigurationFilePath") -eq $true)
    {
        Write-Host "` * Creating Steam libraries folders..."

        #
        #  WARNING - It seems that Steam does not like that we modify its config file (and reset it).
        #            TODO: Find a workaround to automatically register the libraries
        #
        # Clear the previous configuration (as some drives may have been removed)
        # Write-Host "` `  - Clear previous configuration" -NoNewLine
        # (Get-Content $SteamConfigurationFilePath) -replace ".*BaseInstallFolder_[0-9].*$", "" | Out-File $SteamConfigurationFilePath
        # (Get-Content $SteamLibraryConfigurationFilePath) -replace "`t`"[0-9]`".*$", "" | Out-File $SteamLibraryConfigurationFilePath
        # Write-Host "` - Success"

        # CONFIG
        # $NewConfigItems = ""

        # LIB CONFIG - Remove the ending bracket
        # (Get-Content $SteamLibraryConfigurationFilePath) -replace "}", "" | Out-File $SteamLibraryConfigurationFilePath

        $volumes = Get-Volume
        For ($counter=0; $counter -lt $volumes.Length; $counter++)
        {
            $volume = $volumes[$counter]
            $volumeLetter = $volume.DriveLetter
            $libindex = $counter + 1
            $SteamLibraryLocation = "$volumeLetter`:\CloudRIG\GameLibraries\SteamLibrary"
            $SteamLibraryLocationEscaped = $SteamLibraryLocation -replace '\\','\\'

            # If the folders does not already exists
            If ((Test-Path -Path $SteamLibraryLocation) -eq $false)
            {
                Write-Host "` `  - Creating directory $SteamLibraryLocation..." -NoNewLine
                New-Item -Path $SteamLibraryLocation -ItemType directory -Force | Out-Null
                Write-Host "` - Success"
            }

            # # CONFIG FILE
            # # Check if the steam file already contains the configuration for this drive
            # $IsSteamConfigurationFileAlreadyInit = Get-Content "$SteamConfigurationFilePath" | %{ $_ -match [RegEx]::Escape("$SteamLibraryLocation") } # Use RegExp class to escape path backslashes
            # If ($IsSteamConfigurationFileAlreadyInit -contains $false)
            # {
            #     Write-Host "` `  - Add library $SteamLibraryLocation in configuration file (index $counter)" -NoNewLine
            #     $NewConfigItems = "$NewConfigItems`t`t`t`t`"BaseInstallFolder_$libindex`"`t`t`"$SteamLibraryLocationEscaped`"`n"
            #     Write-Host "` - Success"
            # }

            # # LIBRARYFOLDERS FILE
            # # Check if the steam file already contains the configuration for this drive
            # $IsSteamLibraryConfigurationFileAlreadyInit = Get-Content "$SteamLibraryConfigurationFilePath" | %{ $_ -match [RegEx]::Escape("$SteamLibraryLocation") } # Use RegExp class to escape path backslashes
            # If ($IsSteamLibraryConfigurationFileAlreadyInit -contains $false)
            # {
            #     Write-Host "` `  - Add library $SteamLibraryLocation in library configuration file (index $counter)" -NoNewLine
            #     Add-Content $SteamLibraryConfigurationFilePath "`t`"$libindex`"`t`t`"$SteamLibraryLocationEscaped`""
            #     Write-Host "` - Success"
            # }
        }

        # # CONFIG - Re-add the line that is going to be replaces
        # $NewConfigItems = "$NewConfigItems`t`t`t`t`"Accounts`""
        # # Add the content in the file
        # (Get-Content $SteamConfigurationFilePath) -replace "`t`t`t`t`"Accounts`"", "$NewConfigItems" | Out-File $SteamConfigurationFilePath

        # # LIB CONFIG - Re-add the ending bracket
        # Add-Content $SteamLibraryConfigurationFilePath "}"

        # # LIB CONFIG - Cleanup blank lines
        # (Get-Content $SteamLibraryConfigurationFilePath) -notmatch '^\s*$' | Out-File $SteamLibraryConfigurationFilePath
    }
}