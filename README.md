# CloudRIG AWS AMI Factory

This repository contains the tool used to generated the CloudRIG AWS AMIs. 

## Usage

You can use the CloudRIG AMIs without the desktop app. 

For the moment the AMI is only published in eu-west-1 (Ireland).

You MUST use a g4dn.xlarge instance to run the AMI correctly (as the drivers installed only matches the g4 graphic cards).
Average spot price as of 2020-11-13 is ~$0.36 which is the better balance between price and performances.  

You instance profile should at least contains the Amazon SSM access and the following permissions : 
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::dcv-license.<REGION>/*"
        }
    ]
}
```

**Windows password not pushed to the console**

There is something in the current version that is blocking the generated windows password push to the AWS Console. 
You can workaround this by defining your own custom password using SSM and `Run-PowerShellScript` command: 

```
net user Administrator "new_password"
``` 

**Access the istance through DCV**
You can remote control (and even play) using the browser-based NICE DCV app. 
```
https://<ec2-instance-public-domain>:8443/
```
Then use the Windows credentials to connect. 


## Included
  * NICE DCV / Parsec / Rainway
  * Steam / Origin / Epic Games / uPlay / Battle.net
  * Latest NVIDIA drivers
  * Google Chrome
  * Razer Surround / VB Cable
  * DirectX 10, 11, 12
  * VC Redist 2010, 2015, 2017, 2019 (both x86 and x64)
  * 7Zip
  * .NET Framework
  * Direct Play
  
## Troubleshooting

### My instance does not show up in the SSM console

Please ensure that the `AmazonSSMManagedInstanceCore` is attached to your EC2 instance profile role. 

## Debug

### Startup scripts logs 

You can find the EC2 Launch v2 logs here `C:\Program Files\Amazon\EC2Launch\logs`.

You can find the CloudRIG startup scripts logs here `C:\CloudRIG\Logs\`. 