# PRTG Uptime SLA
[PRTG Network Monitor](https://www.paessler.com/prtg) doesn't support any kind of System Uptime Sensors by Default, so I created the following three scripts to provide you with the Average Uptime of all sensors in your PRTG Network Monitor Deployment. 

I recently split off the original script to create a Daily and Weekly version of the original Script. That way you can match the results of this Sensor with your SLAs.

## Quick Overview of the Scripts Available 
| Versions        | Description | Recommended Scanning Internval |
|-----------------|:-----------:|:-------------------------------|
| [PRTG_SLA_Overall.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Overall.ps1) | Averages the uptime since the creation for each Sensor |  |
| [PRTG_SLA_Daily.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Daily_v3.ps1) | Averages the uptime of the last 24 Hours for each Sensor |  |
| [PRTG_SLA_Weekly.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA_Weekly_v3.ps1) | Averages the uptime of the last 7 Days for each Sensor |  |

## How-To & Guide
1. How to Install the Script into your PRTG:
  * Navigate to the C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\ and place the script here.
2. Configure the script for your PRTG Server.
  * You only have to edit the User Config portion.
  * **NOTE:** If using Powershell ISE to edit, you will want to "run as admin" so you are able to save the script in this directory.
3. How to setup the Sensor:
  * Create a Group/Device, set the IPv4 address of the device as: **127.0.0.1**
  * Add a **EXEXML Advanced** Sensor and choose from the Drop down, the script you placed earlier.
  * **NOTE:** You will want to set the Scanning Interval according to the Table above.
