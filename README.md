# CloudRIG AWS AMI Factory

This repository contains the tool used to generated the CloudRIG AWS AMIs. 

## Usage

You can use the CloudRIG AMIs without the graphical interface. 

For the moment the AMI is only published in eu-west-1 (Ireland). 

```
cloudrig-win19full-1.0-g4dn.xlarge-2020-11-13_15.16.18
```

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
  
