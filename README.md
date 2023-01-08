### This Project is in the middle of being reworked!
You can check the [Releases](https://github.com/evanlanester/PRTG-Uptime-SLA/releases/tag/v3.0.0-alpha) for the previous functioning.

---

# PRTG Uptime SLA
[PRTG Network Monitor](https://www.paessler.com/prtg) doesn't support any kind of System Uptime Sensor by Default, so I created the following to provide you with the Average Uptime of all sensors in your PRTG Network Monitor Deployment.

## Development Roadmap:
| Feature | Progress | Comments |
|---------| -------- | -------- |
| Official Rework | 100% | Reworked the entire setup focusing on more optimal code. This did mean I have to redo everything. |
| XML to JSON | 75% | Slowly working at moving away from XML to JSON for future proofing. PRTG's API v2 seems to be going the direction of JSON now. |
| Weekly SLA | 25% | Planning to add a parameter that allow for Weekly SLA |
| Yearly SLA | 0% | Planning to add a parameter that allow for Yearly SLA |
| Monthly SLA | 25% | Planning to add a parameter that allow for Monthly SLA |
| Custom SLA | 0% | Planning to add parameters that allow for custom timeframe |
| Group of Sensors SLA | 0% | During my last look at the PRTG API, this wasn't possible. |
| [API Version 2](https://www.paessler.com/support/prtg/api/v2/overview) | 10% | PRTG API Version 2 is currently in Alpha but is looking far more like most modern API's I am currently working with from other software vendors. |
## Quick Overview of what each file does
| Versions        | Description | Recommended Scanning Internval |
|-----------------|:-----------:|:-------------------------------|
| [New-PRTGAPI.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/New-PRTGAPI.ps1) | Sets up Environment Variables to be called by other Powershell files | N/A |
| [PRTG_SLA.ps1](https://github.com/evanlanester/PRTG-Uptime-SLA/blob/master/PRTG_SLA.ps1) | Averages the uptime of all sensors since the creation | > 10 Minutes |

## How-To & Guide
1. How to Install PRTG-UPTIME-SLA with your PRTG:
    * Download and run the **New-PRTGAPI.ps1**
      * This will setup a *prtgapi.json* file in your Custom Sensors folder to be used by the other Powershell Functions.
    * Navigate to the *C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\\* and place all the other .ps1 files here.
2. How to setup the Sensor:
    * Create a Group/Device, set the IPv4 address of the device as: **127.0.0.1**
       * **WARNING:** Using **Localhost** will cause preformance issues!
    * Add a **[EXE/Script Advanced](https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor)** Sensor and choose from the Drop down, the script you placed earlier.
    * **NOTE:** You will want to set the Scanning Interval according to the Table above to limit performance impact on your system.
3. Add the SLA to your dashboards or reports!

## Additional
My script is now posted and available from PRTG's Script World: [Here](https://www.paessler.com/script-world/all/all/all?stats=all&fulltext=SLA&newOnly=false&scroll=342&key=1529760999307)
