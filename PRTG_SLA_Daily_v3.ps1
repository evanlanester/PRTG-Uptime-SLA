### Written by: Evan Lane ###
###   January 20th 2017   ###
###     Version: 3.1      ###
###Updated: July 13th 2017###
#
# PRTG Powershell Script to monitor the average Daily uptime of all sensors.
# Please install in %PRTG Install%\custom sensors\powershell
#

###User Config
$ssl=$false #$true=https | $false=http
$prtgPort="80"
$prtgServer="127.0.0.1"
$prtgUsername="prtgadmin"
$prtgPasshash="1633323351" #Get your Passhash @ http://yourserver/api/getpasshash.htm?username=myuser&password=mypassword
###User Configs End

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

#Init Date | -1 for last 24 hours
$week = (Get-Date).adddays(-1)
$sdate = Get-Date $week -UFormat "%Y-%m-%d-%H-%M-%S"
$edate = Get-Date -UFormat "%Y-%m-%d-%H-%M-%S"

if ($ssl -eq $true){
    $hyperText="https://"
}
Else{
    $hyperText="http://"
}

###Grab all Sensor IDs from List###
if ($port -eq $null){
    $apiurl="$hyperText"+$prtgServer+":"+$port+"/api/table.xml?id=0&content=sensors&columns=objid&username=$prtgUsername&passhash=$prtgPasshash"
}Else{
    $apiurl="$hyperText$prtgServer/api/table.xml?id=0&content=sensors&columns=objid&username=$prtgUsername&passhash=$prtgPasshash"
}
[xml]$ini = (new-object System.Net.WebClient).downloadstring($apiurl)

###Declare Array to put all uptimes into at end of Foreach###
$target = @()

$ini.sensors.item | foreach {
    $sensorapiurl="$hyperText$prtgServer/api/getsensordetails.xml?id="+$_.objid+"&username=$prtgUsername&passhash=$prtgPasshash"
    [xml]$result = (new-object System.Net.WebClient).downloadstring($sensorapiurl)

    $result.histdata.item | foreach{
    $node="coverage"

    ###Remove String Chars from Uptime###
    [string]$strNum = $_.$node.replace(" ","").replace("%","")
        If ($strNum -eq "N/A"){
            return
        }
        Else{
        ###Convert Uptime to Integer then divide to Percentage Value###
        [int]$intNum = [convert]::ToInt32($strNum, 10)
        $target += $intNum
        }
    }
}

$avg = ($target | Measure-Object -Average)
$final = [math]::Round($avg.Average, 3)

###Export Array of Uptime to CSV###
write-host "<prtg>"
    "<result>"
        "<channel>SLA</channel>"
        "<value>$final</value>"
        "<Unit>Custom</Unit>"
        "<CustomUnit>%</CustomUnit>"
        "<VolumeSize></VolumeSize>"
        "<float>1</float>"
    "</result>"
    "<text>The Current SLA is $final</text>"
"</prtg>"
