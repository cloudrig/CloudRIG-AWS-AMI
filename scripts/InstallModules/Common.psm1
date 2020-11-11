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