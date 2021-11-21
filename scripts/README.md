# CloudRIG AMI Preparation script 

**Forked from Parsec Preparation tool**

This script sets up your cloud computer with a bunch of settings and drivers
to make your life easier.  
                    
It's provided with no warranty, so use it at your own risk.

## Installation
Example (version needs to be updated)
```
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
cd C:\
Remove-Item –path C:\CloudRIGInstall –recurse
Remove-Item –path C:\Users\Administrator\Desktop\CloudRIGInstall\ –recurse
New-Item -Path C:\CloudRIGInstall -ItemType directory | Out-Null
Copy-S3Object -BucketName "cloudrig-amifactory" -Key "v1.0/cloudrig-windows-install.zip" -LocalFile "C:\CloudRIGInstall\cloudrig-windows-install.zip"
Expand-Archive "C:\CloudRIGInstall\cloudrig-windows-install.zip" -DestinationPath "C:\CloudRIGInstall\"
cd "C:\CloudRIGInstall\"
& ".\Loader.ps1"
```

Once the script is finished reboot a first time. Then connect via VNC (RDP is not working) run the following command:
```
displayswitch.exe /internal
```
This will ensure that the second fake screen (Generic Non-PNP Monitor) is disabled.


## Compatibility 

This tool supports:

### OS:
Server 2016  
Server 2019
                    
### CLOUD SKU:
AWS g3.4xlarge    (Tesla M60)  
AWS g2.2xlarge    (GRID K520)  
AWS g4dn.xlarge   (Tesla T4 with vGaming driver)  
AWS g4ad.xlarge   (AMD V520)
Azure NV6         (Tesla M60)  
Paperspace P4000  (Quadro P4000)  
Paperspace P5000  (Quadro P5000)  
Google P100 VW    (Tesla P100 with Virtual Workstation Driver)  
Google P4 VW      (Tesla P4 with Virtual Workstation Driver)  
Google T4 VW      (Tesla T4 with Virtual Workstation Driver)  

### RDP:  
Only use RDP to intially setup the instance. Rainway and RDP are not compatible (especially if you use RDP to log in). Always use the auto logon tool to make the machine log in automatically, and use VNC/Teamviewer for management if required.

### VNC:
AWS, Azure and Google machines will be automatically installed with VNC for troubleshooting purposes. VNC runs with elevated privileges and is able to function in certain situations where Parsec cannot. VNC uses port TCP 5900 (which you will need to manually enable in your instance security group settings), and has a default password of 4ubg9sde. If you open port 5900, make sure to only allow connections to port 5900 from your IP, and change the default password immediately on login — please do these two things. It’s a major security risk if you don’t.

### Issues:
Q. Stuck at 24%  
A. Keep waiting, this installation takes a while.

Q. Parsec won't open  
A. Use Parsec Service Manager on the desktop to open and sign into Parsec.

Q. My cloud machine is stuck at 1366x768  
A. You should delete your machine and use the GRID Virtual Workstation variety provided by your cloud provider (it's a check box on GCP)

Q. I made a mistake when adding my AWS access key or I want to remove it on my G4DN Instance  
A. Open Powershell and type `Remove-AWSCredentialProfile -ProfileName GPUUpdateG4Dn` - This will remove the profile from the machine.

Q. What about GPU X or Cloud Server Y - when will they be supported?  
A. That's on you to test the script and describe the errors you see.



