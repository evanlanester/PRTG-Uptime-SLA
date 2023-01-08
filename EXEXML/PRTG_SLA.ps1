#PRTG_SLA.ps1
#region Custom Functions
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
    
Function DebugLog {
param (
    [Parameter(Mandatory=$true)]
    $debugMessage
)
$scriptLog = $MyInvocation.MyCommand.Name
If ($debug -eq $true) {
    Write-Debug -Message $debugMessage >> $env:TEMP\$scriptLog".log"
}
}
#endregion

### Accept SSL/TLS Unsigned Certs ###
AcceptTLSCerts
    
### Confirm Environment Variables Exist, otherwise prompt to setup or accept parameters.
If (Test-Path "${env:ProgramFiles(x86)}\PRTG Network Monitor\Custom Sensors\prtgapi.json") {
    [string]$GetEnvironmentVariables = Get-Content -Path "${env:ProgramFiles(x86)}\PRTG Network Monitor\Custom Sensors\prtgapi.json"
    $EnvironmentVariables = ConvertFrom-JSON $GetEnvironmentVariables
    # Parameters:
    [boolean]$debug = $true
    [boolean]$ssl = $EnvironmentVariables.SSL
    [int]$prtgPort = $EnvironmentVariables.PORT
    [string]$prtgServer = $EnvironmentVariables.SERVER
    [string]$prtgUsername = $EnvironmentVariables.USERNAME
    [string]$prtgPasshash = $EnvironmentVariables.PASSHASH
} Else {
    Write-Error "No existing Environment Variables Detected!"
    . "${env:ProgramFiles(x86)}\PRTG Network Monitor\Custom Sensors\Setup-PRTGAPI.ps1"
    New-PRTGAPI
}

try {
    switch ($ssl) {
        $true {$hyperText="https://"}
        $false {$hyperText="http://"}
    }

    if (($prtgPort -ne "443") -or ($prtgPort -ne "80")) {
        $APIRoot="$hyperText"+"$prtgServer"+":"+$prtgPort+"/api/"
    } else {
        $APIRoot="$hyperText"+"$prtgServer"+"/api/"
    }
    DebugLog -debugMessage "API Root: $APIRoot"
    DebugLog -debugMessage "User Requesting API Calls: $prtgUsername"

    $APICall = $APIRoot+"table.xml?id=0&content=sensors&columns=objid&username=$prtgUsername&passhash=$prtgPasshash"
    [xml]$ini = (new-object System.Net.WebClient).downloadstring($APICall)
    DebugLog -debugMessage "Calling: $APICall..."

    $result = @()

    $ini.sensors.item | ForEach-Object {
        $sensorAPICall=$APIRoot+"getsensordetails.xml?id="+$_.objid+"&username=$prtgUsername&passhash=$prtgPasshash"
        DebugLog -debugMessage "Calling: $sensorAPICall..."
        [xml]$sensorDetails = (new-object System.Net.WebClient).downloadstring($sensorAPICall)
        $sensorData="uptime"
        ### Remove String Chars from Uptime ###
        [string]$strNum = $sensorDetails.sensordata.$sensorData.innertext.replace("%","").replace(".","")
        ### Check For If Statement ###
        if ($strNum -eq "N/A") { 
            return
        } else {
        ### Convert Uptime to Integer then divide to Percentage Value ###
            [int]$intNum = [convert]::ToInt32($strNum, 10)
            $result += $intNum/10000
        }
    }

    $avgResult = ($result | Measure-Object -Average)
    $roundedResult = [math]::Round($avgResult.Average, 3)

$FormatOutput = @"
<prtg>
    <result>
        <channel>SLA</channel>
        <value>$roundedResult</value>
        <unit>Percent</unit>
        <limitminwarning>99.9</limitminwarning>
        <limitwarningmsg>The SLA is in warning state. Please review.</limitwarningmsg>
        <limitmode>1</limitmode>
        <float>1</float>
    </result>
    <text>The current SLA is $roundedResult</text>
</prtg>
"@

Write-Host $FormatOutput
}
catch {
$ErrorMessage = "An error occurred: `n" + $_
$FormatOutput = @"
<prtg>
    <error>1</error>
    <text>$ErrorMessage</text>
</prtg>
"@

Write-Host $FormatOutput
}