
function cloudprovider {
    #finds the cloud provider that this VM is hosted by
    $gcp = $(
    try {
        (Invoke-WebRequest -uri http://metadata.google.internal/computeMetadata/v1/ -Method GET -header @{'metadata-flavor'='Google'} -TimeoutSec 5)
    }
    catch {
    }
    )

    $aws = $(
    Try {
        (Invoke-WebRequest -uri http://169.254.169.254/latest/meta-data/ -TimeoutSec 5)
    }
    catch {
    }
    )

    $paperspace = $(
    Try {
        (Invoke-WebRequest -uri http://metadata.paperspace.com/meta-data/machine -TimeoutSec 5)
    }
    catch {
    }
    )

    $azure = $(
    Try {(Invoke-WebRequest -Uri "http://169.254.169.254/metadata/instance?api-version=2018-10-01" -Headers @{Metadata="true"} -TimeoutSec 5)}
    catch {}
    )


    if ($GCP.StatusCode -eq 200) {
        "Google"
    }
    Elseif ($AWS.StatusCode -eq 200) {
        "AWS"
    }
    Elseif ($paperspace.StatusCode -eq 200) {
        "Paperspace"
    }
    Elseif ($azure.StatusCode -eq 200) {
        "Azure"
    }
    Else {
        "Generic"
    }
}


add-type  @"
        using System;
        using System.Collections.Generic;
        using System.Text;
        using System.Runtime.InteropServices;

        namespace ComputerSystem
        {
            public class LSAutil
            {
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_UNICODE_STRING
                {
                    public UInt16 Length;
                    public UInt16 MaximumLength;
                    public IntPtr Buffer;
                }

                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_OBJECT_ATTRIBUTES
                {
                    public int Length;
                    public IntPtr RootDirectory;
                    public LSA_UNICODE_STRING ObjectName;
                    public uint Attributes;
                    public IntPtr SecurityDescriptor;
                    public IntPtr SecurityQualityOfService;
                }

                private enum LSA_AccessPolicy : long
                {
                    POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
                    POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
                    POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
                    POLICY_TRUST_ADMIN = 0x00000008L,
                    POLICY_CREATE_ACCOUNT = 0x00000010L,
                    POLICY_CREATE_SECRET = 0x00000020L,
                    POLICY_CREATE_PRIVILEGE = 0x00000040L,
                    POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
                    POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
                    POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
                    POLICY_SERVER_ADMIN = 0x00000400L,
                    POLICY_LOOKUP_NAMES = 0x00000800L,
                    POLICY_NOTIFICATION = 0x00001000L
                }

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaRetrievePrivateData(
                            IntPtr PolicyHandle,
                            ref LSA_UNICODE_STRING KeyName,
                            out IntPtr PrivateData
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaStorePrivateData(
                        IntPtr policyHandle,
                        ref LSA_UNICODE_STRING KeyName,
                        ref LSA_UNICODE_STRING PrivateData
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaOpenPolicy(
                    ref LSA_UNICODE_STRING SystemName,
                    ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
                    uint DesiredAccess,
                    out IntPtr PolicyHandle
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaNtStatusToWinError(
                    uint status
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaClose(
                    IntPtr policyHandle
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaFreeMemory(
                    IntPtr buffer
                );

                private LSA_OBJECT_ATTRIBUTES objectAttributes;
                private LSA_UNICODE_STRING localsystem;
                private LSA_UNICODE_STRING secretName;

                public LSAutil(string key)
                {
                    if (key.Length == 0)
                    {
                        throw new Exception("Key lenght zero");
                    }

                    objectAttributes = new LSA_OBJECT_ATTRIBUTES();
                    objectAttributes.Length = 0;
                    objectAttributes.RootDirectory = IntPtr.Zero;
                    objectAttributes.Attributes = 0;
                    objectAttributes.SecurityDescriptor = IntPtr.Zero;
                    objectAttributes.SecurityQualityOfService = IntPtr.Zero;

                    localsystem = new LSA_UNICODE_STRING();
                    localsystem.Buffer = IntPtr.Zero;
                    localsystem.Length = 0;
                    localsystem.MaximumLength = 0;

                    secretName = new LSA_UNICODE_STRING();
                    secretName.Buffer = Marshal.StringToHGlobalUni(key);
                    secretName.Length = (UInt16)(key.Length * UnicodeEncoding.CharSize);
                    secretName.MaximumLength = (UInt16)((key.Length + 1) * UnicodeEncoding.CharSize);
                }

                private IntPtr GetLsaPolicy(LSA_AccessPolicy access)
                {
                    IntPtr LsaPolicyHandle;

                    uint ntsResult = LsaOpenPolicy(ref this.localsystem, ref this.objectAttributes, (uint)access, out LsaPolicyHandle);

                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaOpenPolicy failed: " + winErrorCode);
                    }

                    return LsaPolicyHandle;
                }

                private static void ReleaseLsaPolicy(IntPtr LsaPolicyHandle)
                {
                    uint ntsResult = LsaClose(LsaPolicyHandle);
                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaClose failed: " + winErrorCode);
                    }
                }

                public void SetSecret(string value)
                {
                    LSA_UNICODE_STRING lusSecretData = new LSA_UNICODE_STRING();

                    if (value.Length > 0)
                    {
                        //Create data and key
                        lusSecretData.Buffer = Marshal.StringToHGlobalUni(value);
                        lusSecretData.Length = (UInt16)(value.Length * UnicodeEncoding.CharSize);
                        lusSecretData.MaximumLength = (UInt16)((value.Length + 1) * UnicodeEncoding.CharSize);
                    }
                    else
                    {
                        //Delete data and key
                        lusSecretData.Buffer = IntPtr.Zero;
                        lusSecretData.Length = 0;
                        lusSecretData.MaximumLength = 0;
                    }

                    IntPtr LsaPolicyHandle = GetLsaPolicy(LSA_AccessPolicy.POLICY_CREATE_SECRET);
                    uint result = LsaStorePrivateData(LsaPolicyHandle, ref secretName, ref lusSecretData);
                    ReleaseLsaPolicy(LsaPolicyHandle);

                    uint winErrorCode = LsaNtStatusToWinError(result);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("StorePrivateData failed: " + winErrorCode);
                    }
                }
            }
        }
"@

Function TestCredential {
    param
    (
        [PSCredential]$Credential
    )
    try {
        Start-Process -FilePath cmd.exe /c -Credential ($Credential)
    }
    Catch {
        If ($Error[0].Exception.Message) {
            $Error[0].Exception.Message
            Throw
        }
    }
}

function Set-AutoLogon {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [PSCredential]$Credential
    )
    Try {
        if ($Credential.GetNetworkCredential().Domain) {
            $DefaultDomainName = $Credential.GetNetworkCredential().Domain
        }
        elseif ((Get-WMIObject Win32_ComputerSystem).PartOfDomain) {
            $DefaultDomainName = "."
        }
        else {
            $DefaultDomainName = ""
        }

        if ($PSCmdlet.ShouldProcess(('User "{0}\{1}"' -f $DefaultDomainName, $Credential.GetNetworkCredential().Username), "Set Auto logon")) {
            Write-Verbose ('DomainName: {0} / UserName: {1}' -f $DefaultDomainName, $Credential.GetNetworkCredential().Username)
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "AutoAdminLogon" -Value 1
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultDomainName" -Value ""
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultUserName" -Value $Credential.UserName
            Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "AutoLogonCount" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultPassword" -ErrorAction SilentlyContinue
            $private:LsaUtil = New-Object ComputerSystem.LSAutil -ArgumentList "DefaultPassword"
            $LsaUtil.SetSecret($Credential.GetNetworkCredential().Password)
            "Auto Logon Configured"
            Remove-Variable Credential
        }
    }
    Catch {
        $Error[0].Exception.Message
        Throw
    }
}


Function GetInstanceCredential {

    Try {
        $Credential = Get-Credential -Credential $null
        Try {
            TestCredential -Credential $Credential
        }
        Catch {
            "Credentials Incorrect"
        }
        Try {
            Set-AutoLogon -Credential $Credential
        }
        Catch {
            $Error[0].Exception
            "Retry?"
            $ReadHost = Read-Host "(Y/N)"
            Switch ($ReadHost)
            {
                Y {
                    GetInstanceCredential
                }
                N {
                }
            }
        }

    }
    Catch {
        "You pressed cancel, retry?"
        $ReadHost = Read-Host "(Y/N)"
        Switch ($ReadHost)
        {
            Y {
                GetInstanceCredential
            }
            N {
            }
        }
    }
}

Function PromptUserAutoLogon {
    param (
        [switch]$DontPromptPasswordUpdateGPU
    )
    $CloudProvider = CloudProvider
    If ($DontPromptPasswordUpdateGPU) {
    }
    ElseIf ($CloudProvider -eq "Paperspace") {
    }
    Else {
        "Detected $CloudProvider"
        Write-Host @"
Do you want this computer to log on to Windows automatically?
(Y): This is good when you want the cloud computer to boot straight to Parsec but is less secure as the computer will not be protected by a password at start up
(N): If you plan to log into Windows with RDP then connect via Parsec, or have been told you don't need to set this up
"@ -ForegroundColor Black -BackgroundColor Red
        $ReadHost = Read-Host "(Y/N)"
        Switch ($ReadHost)
        {
            Y {
                GetInstanceCredential
            }
            N {
            }
        }
    }
}

PromptUserAutoLogon