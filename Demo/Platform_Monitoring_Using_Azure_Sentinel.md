## Platform Monitoring Using Azure Sentinel

Azure Sentinel is a cloud-native Security Information and Event Management (SIEM) and Security Orchestration Automated Response (SOAR) tool. It enables comprehensive platform monitoring by providing centralized visibility, advanced threat detection, and automated responses to security incidents across various platforms. Here's a brief documentation:
Key Features for Platform Monitoring
### 1. Centralised Monitoring  
Azure Sentinel acts as a hub for collecting and analyzing data from multiple sources, giving a unified view of your platform's health and security posture.
o	Aggregate and correlate data from multiple platforms such as Azure services, on-premises servers, virtual machines, and third-party applications like AWS, Google Cloud, and security appliances.
o	Monitor activity across platforms including infrastructure, applications, network devices, and cloud workloads.

For example: Monitor both Azure Active Directory (Azure AD) for unusual login attempts and network firewalls for unauthorized traffic in a single dashboard.
### 2. Advanced Threat Detection  
o	Azure Sentinel uses built-in analytics, AI, and machine learning to detect suspicious behaviours and potential threats that may compromise your platform.
o	Detect anomalies like unauthorized access, unusual data transfers, and potential compromises.
o	Integrate with Microsoft's threat intelligence feed to identify known attack signatures and malicious actors.
o	For example, Detect and alert when a user downloads a high volume of sensitive files and simultaneously logs in from a suspicious IP address.
### 3. Customizable Dashboards 
Sentinel provides dynamic and interactive dashboards, also known as workbooks, to visualize and track your platform's performance and security metrics.
o	Build visualizations for platform health, compliance, and security posture.  
o	Use ready-made templates for common scenarios like monitoring failed login attempts or auditing administrative actions.
o	Create tailored dashboards to display metrics specific to your platform, such as API usage or resource utilization to track key performance indicators (KPIs) and alerts.
o	Dive into specific data points for detailed investigation.
o	Like build a dashboard that shows top login locations, recently flagged alerts, and ongoing incidents in one view.
### 4. Integration with Other Tools  
o	Azure Sentinel seamlessly integrates with both Microsoft services and third-party solutions, enabling comprehensive platform monitoring.
o	Easily connect to tools like Microsoft Defender, Azure Security Center, and Azure Monitor for enriched insights.
o	Integrate with non-Microsoft platforms, such as Palo Alto firewalls, Cisco devices, or AWS logs.
o	Use APIs to ingest data from custom or unsupported sources.
o	Like Combine logs from Azure Virtual Machines with firewall logs from Palo Alto to identify cross-platform attack vectors.
### 5. Automated Responses
o	Sentinel’s automation capabilities help reduce manual effort and response time during incidents.
o	Automate responses using Logic Apps to perform actions like notifying administrators, notifying the security team, isolating a compromised system, disabling a user account, or blocking malicious IPs.
o	Trigger specific actions based on alert severity, type, or source
o	Minimize response times and mitigate risks effectively.
o	Like If an alert is triggered for an unusual login from a blacklisted IP, a playbook can disable the user account and notify the security team automatically
### 6. Proactive Threat Hunting
o	Sentinel provides tools for advanced threat hunting, enabling security teams to proactively search for potential risks and vulnerabilities.
o	Use KQL (Kusto Query Language) to search for specific patterns or indicators of compromise (IoCs) across log.
o	Save hunting results for later analysis or correlation with other events.
o	Build queries to detect platform-specific threats, such as unauthorized API access or changes to critical configurations.
o	For example, Hunt for repeated failed login attempts followed by a successful login, which could indicate brute force or credential stuffing attacks

## Steps to Implement Platform Monitoring
### 1. Set up Data Connectors  
o	This is the foundation of monitoring in Azure Sentinel, where you integrate various data sources to collect logs and telemetry.
o	Identify key platforms and services that need monitoring (e.g., Azure VMs, Azure AD, firewalls, or third-party applications).  
o	Use built-in connectors for Microsoft services like Microsoft Defender, Azure AD, and Azure Activity.
o	Configure custom data ingestion for unsupported or third-party platforms using the Common Event Format (CEF), Syslog, or REST APIs.
o	Connect third-party tools such as Palo Alto Networks, Fortinet, and AWS.
o	Example Connect Azure AD to monitor login activities and a third-party firewall to track network traffic.
### 2. Define Monitoring Metrics 
Once data sources are connected, determine what metrics and activities are crucial for your platform's health and security.
o	Identify critical activities (e.g., failed login attempts, bulk file downloads, or configuration changes).
o	Define thresholds and baselines for normal and abnormal activities (e.g., 50 failed logins in an hour might indicate a brute-force attack).
o	Focus on both operational metrics (e.g., CPU or memory usage) and security metrics (e.g., privileged account activity).
### 3. Define Analytics Rules 
Detection rules are essential for identifying potential threats or operational issues.
o	Use KQL (Kusto Query Language) to create rules that analyze incoming data for anomalies or specific patterns.
o	Leverage built-in analytics templates to detect common security threats like malware infections or suspicious logins.
o	Customize rules for platform-specific requirements, such as unauthorized access attempts, unauthorized API access, unusual login patterns, high resource consumption or data exfiltration.
o	For example, we can create a rule to detect when a user downloads a large number of files and changes their sensitivity labels within a short timeframe
### 4. Enable Threat Hunting  
Proactive threat hunting is vital for identifying hidden threats that might evade detection rules.
o	Utilize hunting queries to proactively search for threats across your data. Use KQL to query logs for suspicious activities or anomalies.
o	Focus on platform-specific risks, such as unauthorized data access or unexpected configuration changes
o	Example scenarios: detecting lateral movement, unusual privilege escalations, or Investigate repeated access to sensitive files followed by external data transfers.
### 5. Set up Alerts and Incidents
o	Configure alerts for detection rules with appropriate severity levels (e.g., Low, Medium, High) to notify the team when a rule is triggered.  
o	Define notification methods, such as email or integration with incident management tools like ServiceNow.
o	Automatically group related alerts into incidents for streamlined investigation and response.
o	Use case like, Send a high-priority alert to the SOC team if an administrator account logs in from an unusual location.
### 6. Visualize with Workbooks 
Dashboards help visualize and track platform activity in real-time
o	Use built-in or custom workbooks to visualize platform performance, compliance, and security metrics.  
o	Example: Create a workbook to monitor login attempts, failed logins, and unusual geographic access.
### 7. Automate Responses  
Automation helps streamline responses to detected issues, reducing response time and manual effort.
o	Develop playbooks using Azure Logic Apps to automate incident responses.
o	Use playbooks for scenarios like alert-based notifications, blocking suspicious IP addresses, or isolating compromised resources.  
o	Example: When a critical alert is triggered, notify the security team and disable the affected user account automatically. 
o	If a brute force attack is detected, a playbook could lock the affected user account, block the attacking IP, and notify the SOC team

## Common Use Cases
### 1. Cloud Infrastructure Monitoring  
This use case focuses on identifying and understanding security threats in real time.
o	Detect potential security threats like phishing attacks, malware infections, or unauthorized access attempts.
o	Monitor Azure resources such as Virtual Machines, Storage Accounts, and Azure AD for unusual activity.  
o	Detect over-permissioned accounts and configuration drifts.
Example: If an unusual sign-in is detected from a foreign IP address, Azure Sentinel can generate an alert. Analysts can use Sentinel to trace the user’s activity and determine if it’s a legitimate or malicious attempt
### 2. Privileged Access Monitoring  
o	Track activities of privileged accounts (e.g., administrators) to ensure they’re not being abused or compromised.  
o	Detect risky behaviours like logging in from suspicious locations or accessing sensitive resources.
Example: Alert when a privileged user logs in from an untrusted device or performs bulk data exports.
### 3. Data Exfiltration Detection 
Azure Sentinel helps monitor for unusual data transfers that might indicate data theft or leakage.
o	Detect activities like bulk file downloads, unauthorized file sharing, or large data transfers to external locations.  
o	Correlate multiple events to identify patterns that could indicate a data breach.
Example: If a user downloads a significant number of sensitive files and then sends them to an external email within a short time frame, it can trigger an alert.
### 4. Unusual Sign-In Behaviour Analysis
This involves monitoring for deviations in user sign-in patterns
o	Identify suspicious login behaviours such as sign-ins from new locations, devices, or IP ranges.  
o	Detect impossible travel scenarios, where a user logs in from geographically distant locations within an improbable timeframe.
### 5. Malware Outbreak Identification  
Identify and respond to malware infections that might spread across the environment
o	Monitor endpoints for indicators of compromise (IoCs) like unusual file activity, process execution, or communication with malicious domains.
o	Correlate malware-related alerts across multiple devices to detect potential outbreaks.
Example: Multiple devices reporting connections to the same suspicious domain might indicate a malware outbreak
### 6. Threat Intelligence Integration  
Enhancing monitoring by incorporating external threat intelligence feeds.
o	Use threat intelligence to enrich logs and alerts, identifying known malicious IPs, domains, or file hashes.
o	Correlate detected threats with global threat intelligence to assess their severity.
Example: Block traffic from an IP flagged in threat intelligence feeds as part of a botnet.

## Benefits
Scalability: Easily scale to monitor large and complex platforms.  
Unified Visibility: Consolidate logs and alerts from multiple sources for a unified view.  
Proactive Defence: Use advanced analytics and threat intelligence for proactive threat detection.  
Cost Efficiency: Pay-as-you-go model, with the ability to optimize costs by fine-tuning data ingestion 
