# Set a default password for administrator
$username = "Administrator"
$password = "P8Gej4T6AnAtu7QxX2mqG@6t_2uL8Bc6W@6YAq8Utzk2AR6b62xYB63*yuEZGNhP"
net user $username $password

Write-Output "Running Loader.ps1 as Administrator..."
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.Verb = 'RunAs'
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "-file $path\parsectemp\PostInstall\PostInstall.ps1"
$pinfo.Username = "Administrator"
$pinfo.Password = (ConvertTo-SecureString -String $password -AsPlainText -Force)
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start()
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host "stderr: $stderr"
Write-Host "stdout: $stdout"
Write-Host "exit code: " + $p.ExitCode