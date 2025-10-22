# Detection Rule: Suspicious Scheduled Task Creation or Modification

## MITRE ATT&CK Technique

* **Technique ID:** T1053.005
* **Technique Name:** Scheduled Task/Job: Scheduled Task
* **Tactic:** Execution / Persistence

## Description

This analytic detects the creation or modification of scheduled tasks, which can indicate persistence or execution mechanisms being established by an adversary. Attackers often use scheduled tasks to execute malicious payloads at specific intervals or system events using PowerShell or schtasks.exe.
## Data Sources

* **DeviceProcessEvents (Microsoft Defender for Endpoint)**
* **SecurityEvent (Event ID 4698, 4702)**

## Detection Logic (KQL)

```kql
// Detection of new or modified scheduled tasks
union isfuzzy=true
DeviceProcessEvents
| where FileName =~ "schtasks.exe" or FileName =~ "powershell.exe"
| where ProcessCommandLine has_any (" /create", " /change", "New-ScheduledTask", "Register-ScheduledTask", "DownloadString", "IEX", "Invoke-Expression")
| project Timestamp, DeviceName, InitiatingProcessAccountName, ParentProcessFileName, ProcessCommandLine
// Detection via SecurityEvent logs (Event ID 4698 = Task Created, 4702 = Task Updated)
| union (
    SecurityEvent
    | where EventID in (4698, 4702) // Task created or updated
    | project TimeGenerated, Computer, Account, EventID, CommandLine
)
| order by Timestamp desc
```

## Possible False Positives

* Legitimate administrative task creation using scripts or system management tools.
* Scheduled tasks created by patch management systems or software updates.

## Mitigation

* Investigate the process command line to confirm if this was an authorized admin activity.
* Review the associated task name and script path for malicious payloads.
* Check if similar tasks are created across multiple hosts (possible lateral persistence).
* Restrict permissions to create or modify scheduled tasks.
* Monitor and alert on unexpected users creating tasks.

## Testing

To simulate this behavior safely:

```powershell
schtasks /create /tn "AtomicTest_T1053" /tr "notepad.exe" /sc once /st 00:10
```
## Mock Log
[DeviceProcessEvent](https://github.com/RakeshPrasad21/Rakesh-Prasad/blob/main/Demo/DeviceProcessEvents_T1053_005_mock.csv)
[SecurityEvent](https://github.com/RakeshPrasad21/Rakesh-Prasad/blob/main/Demo/ScheduledTaskEvents_T1053_005_mock.csv)

## References

* [MITRE ATT&CK: T1053.005](https://attack.mitre.org/techniques/T1053/005/)
* [Atomic Red Team: T1053.005](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1053.005/T1053.005.md)
