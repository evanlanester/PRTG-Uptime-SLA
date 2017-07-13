# PRTG Uptime SLA
[PRTG Network Monitor](https://www.paessler.com/prtg) doesn't support any kind of System Uptime Sensors by Default, so I created the following three scripts to provide you with the Average Uptime of all sensors in your PRTG Network Monitor Deployment. 

I recently split off the original script to create a Daily and Weekly version of the original Script. That way you can match the results of this Sensor with your SLAs.

## Quick Overview of the Scripts Available 
| Versions        | Description | Recommended Scanning Internval |
|-----------------|:-----------:|:-------------------------------|
| [PRTG_SLA_Overall.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Overall.ps1) | Averages the uptime since the creation for each Sensor |  |
| [PRTG_SLA_Daily.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Daily_v3.ps1) | Averages the uptime of the last 24 Hours for each Sensor |  |
| [PRTG_SLA_Weekly.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Weekly_v3.ps1) | Averages the uptime of the last 7 Days for each Sensor |  |
