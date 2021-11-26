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

### Gaming via NICE DCV

In order to game via DCV you will need the [desktop app client](https://download.nice-dcv.com/).

Browser access may work, but it will not give good results when gaming, as it does not support QUIC protocol (UDP).

```
https://<ec2-instance-public-domain>:8443/
```

Use the windows credentials to login.

### Change the password without connecting

You can change the password prior connection to the machine via SSM :
https://console.aws.amazon.com/systems-manager/documents/AWS-RunPowerShellScript/description

```powershell
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
  
## Troubleshooting

### My instance does not show up in the SSM console

Please ensure that the `AmazonSSMManagedInstanceCore` is attached to your EC2 instance profile role. 

## Debug

### Startup scripts logs 

You can find the EC2 Launch v2 logs here `C:\Program Files\Amazon\EC2Launch\logs`.

You can find the CloudRIG startup scripts logs here `C:\CloudRIG\Logs\`. 