Function Get-RandomAlphanumericString
{
    [CmdletBinding()]
    Param (
        [int] $length = 8
    )
    Begin{
    }
    Process{
        Write-Output ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length  | % {[char]$_}) )
    }
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

    } Catch {
        return $false
    }
}

function Test-RegistryItemExists {
    # https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path
    )
    try {
        Get-ItemProperty -Path $Path -ErrorAction Stop | Out-Null
        return $true

    } Catch {
        return $false
    }
}

Function Get-SpecialFolder {
    Param([parameter(Mandatory=$true)] [String] $Name)

    return [System.Environment]::GetFolderPath($Name)
}

# Get-HashValue(h,k[,d]) -> h[k] if k in h, else d.  d defaults to $null.
Function Get-HashValue {
    Param (
        [parameter(Mandatory=$true)] [Hashtable] $Hashtable,
        [parameter(Mandatory=$true)] [System.Object] $Key,
        [AllowNull()]                [System.Object] $Default
    )
    If($Hashtable.Keys -contains $Key) {
        return $Hashtable[$Key]
    } Else {
        return $Default
    }
}

# in Powershell v6 we can just use 'ConvertFrom-Json -AsHashtable'
Function ConvertFrom-JsonAsHashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    Param (
        [Parameter(ValueFromPipeline)] $InputObject
    )

    Process {
        If ($null -eq $InputObject) {
            return @{}
        }
        Add-Type -AssemblyName System.Web.Extensions
        $parser = New-Object Web.Script.Serialization.JavaScriptSerializer
        $parser.MaxJsonLength = $InputObject.length
        Write-Output -NoEnumerate $parser.Deserialize($InputObject, @{}.GetType())
    }
}