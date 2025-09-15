https://threathunt.blog/impacket-part-3/
https://vk9-sec.com/impacket-remote-code-execution-rce-on-windows-from-linux/
https://kylemistele.medium.com/impacket-deep-dives-vol-1-command-execution-abb0144a351d


```
let AzureRanges = externaldata(changeNumber: string, cloud: string, values: dynamic)
["https://raw.githubusercontent.com/microsoft/mstic/master/PublicFeeds/MSFTIPRanges/ServiceTags_Public.json"] with(format='multijson')
| mv-expand values
| extend Name = values.name, AddressPrefixes = values.properties.addressPrefixes
| mv-expand AddressPrefixes
| summarize by tostring(AddressPrefixes);
let IPList = externaldata(IPAddress: string)[@"https://raw.githubusercontent.com/SameerErnical/Mannai-ThreatHunting/main/Whitelisted%20IP%20For%20KQL%20Fine%20Tuning/Whitelisted%20Public%20IP%20CGB.csv"] with (format="csv", ignoreFirstRecord=True);
let knownGoodIPs = dynamic([
    "10.0.0.0/8", // Internal network
    "192.168.0.0/16", // Internal network
    "172.16.0.0/12" // Internal network
]);
let knownGoodPorts = dynamic([80, 443, 53, 22, 3389]); // HTTP, HTTPS, DNS, SSH, RDP
let threshold = 100; // Define a threshold for anomaly detection
let MatchedIPs =  DeviceNetworkEvents
    | where not(RemoteIP in (knownGoodIPs)) // Exclude known good IPs
    | where not(RemotePort in (knownGoodPorts)) // Exclude known good ports
    | where ActionType has "ConnectionSuccess"
    | where RemoteIPType =~ "Public"
| evaluate ipv4_lookup(AzureRanges, RemoteIP, AddressPrefixes)
| project RemoteIP;
let processAnomalies = 
    DeviceNetworkEvents
    | where not(RemoteIP in (knownGoodIPs)) // Exclude known good IPs
    | where not(RemotePort in (knownGoodPorts)) // Exclude known good ports
    | where ActionType has "ConnectionSuccess"
    | where RemoteIPType =~ "Public"
	| where not (RemoteIP in (MatchedIPs))
    | summarize count() by InitiatingProcessFileName, RemoteIP, RemotePort, bin(TimeGenerated, 1h)
    | where count_ > threshold; // Filter for anomalies
processAnomalies
| join kind=inner (
    DeviceNetworkEvents
    | where TimeGenerated > ago(1d)
    | project TimeGenerated, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, RemoteIP, RemotePort, LocalIP, LocalPort,  Protocol
) on InitiatingProcessFileName, RemoteIP, RemotePort
| project TimeGenerated, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, RemoteIP, RemotePort, LocalIP, LocalPort,  Protocol, count_
| order by TimeGenerated desc
```


<img width="380" height="403" alt="image" src="https://github.com/user-attachments/assets/9d30ba93-41b3-47d7-924d-2d57218021a2" />

<img width="373" height="395" alt="image" src="https://github.com/user-attachments/assets/43980825-8ccd-4588-952b-19bcd277b24b" />

<img width="378" height="394" alt="image" src="https://github.com/user-attachments/assets/494f6461-26c5-4c16-bda2-6f7f5f47d149" />




