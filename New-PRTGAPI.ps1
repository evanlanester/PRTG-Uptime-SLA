#New-PRTGAPI.ps1
Function New-PRTGAPI {
    <#
    .SYNOPSIS
        Creates a file containing the necessary environment variables for interfacing
        with PRTG's API.
    
    .DESCRIPTION
        New-PRTGAPI is a function that outputs a file called prtgapi.json in your Custom Sensors folder.
        The file contains your PRTG Environments Server Address, SSL Enabled, Port and Credentials necessary
        to interface with PRTG API.
    
    .PARAMETER ssl
        The SSL Parameter accepts true or false depending on whether your PRTG instance is running
        TLS/SSL or not. HIGHLY RECOMMEND RUNNING WITH SSL/TLS OR ELSE ALL DATA AND CREDENTIALS ARE
        IN PLAIN TEXT. Default is 1. Set to 0 for no SSL
    
    .PARAMETER prtgPort
        The prtgPort specifies the port that your server is running on. Default is 443.
    
    .PARAMETER prtgServer
        The prtgServer specifies the IP address or URL that PRTG is accessible on. Default is 127.0.0.1.
    
    .EXAMPLE
        New-PRTGAPI -ssl $false -prtgPort 8080 -prtgServer 192.168.1.21 -prtgUsername evanlane -prtgPassword SuperSecure1!
    
    .EXAMPLE
        New-PRTGAPI -prtgUsername evanlane -prtgPassword SuperSecure1!
    
    .INPUTS
        Switch
        Boolean
        String
        SecureString
    
    .OUTPUTS
        File
    
    .NOTES
        Author:  Evan Lane
        Website: https://evanlane.me
        GitHub: https://github.com/evanlanester
    #>
    param (
        [Parameter(Mandatory=$false)]
        [Boolean]$ssl = 1,
        [Parameter(Mandatory=$false)]
        [String]$prtgPort = "443",
        [Parameter(Mandatory=$false)]
        [String]$prtgServer = "127.0.0.1",
        [Parameter(Mandatory=$true)]
        [String]$prtgUsername,
        [Parameter(Mandatory=$true)]
        [SecureString]$prtgPassword
    )
    
    #region NestedFunctions
    #ConvertFrom-SecureString-AsPlainText - For Legacy Powershell Support.
    Function ConvertFrom-SecureString-AsPlainText {
        param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [SecureString]$SecureString
        )
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        $PlainTextString
    }
    
    #Allow self-signed or unsigned Certs
    Function AcceptTLSCerts {
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    }
    #endregion
    AcceptTLSCerts
    
    ### Change HTTP based on whether SSL is enabled.
    switch ($ssl) {
        $true {$hyperText="https://"}
        $false {$hyperText="http://"}
    }
    
    ### Change URL for API call, based on Port.
    if (($port -ne "443") -or ($port -ne "80")) {
        $APIRoot="$hyperText"+"$prtgServer"+":"+$port+"/api/"
    } else {
        $APIRoot="$hyperText"+"$prtgServer"+"/api/"
    }
    
    #https://127.0.0.1/controls/apikeys.htm?id=100&targeturl=/edituser.htm?id=100%26tabid=5
    
    ### Convert Password to Clear text to request passhash
    [string]$prtgPassword = ConvertFrom-SecureString-AsPlainText -SecureString $prtgPassword
    $APICall = $APIRoot+"getpasshash.htm?username=$prtgUsername&password=$prtgPassword"
    $prtgPassword = $null # Clearing Cleartext password.
    $prtgPasshash = (new-object System.Net.WebClient).downloadstring($APICall)
    
    ### Format Environment Variables
    $EnvironmentVariables = @"
    {
        "SSL":"$ssl",
        "PORT":"$prtgPort",
        "SERVER":"$prtgServer",
        "USERNAME":"$prtgUsername",
        "PASSHASH":"$prtgPasshash"
    }
"@
    
    ### Output JSON formatted environment variables
    $EnvironmentVariables | Out-File -FilePath "${ENV:ProgramFiles(x86)}\PRTG Network Monitor\Custom Sensors\prtgapi.json"
    }
    
    # Run Function.
    New-PRTGAPI