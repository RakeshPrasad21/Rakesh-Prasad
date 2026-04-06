
#Connect-AzureAD
$MIGuid = ""
$MI = Get-AzureADServicePrincipal -ObjectId $MIGuid

$ThreatProtectionAppId = "8ee8fdad-f234-4243-8f3b-15c294843740"
$PermissionName = "AdvancedHunting.Read.All"

$ThreatServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$ThreatProtectionAppId'"
$AppRole = $ThreatServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}
New-AzureAdServiceAppRoleAssignment -ObjectId $MI.ObjectId -PrincipalId $MI.ObjectId `
    -ResourceId $ThreatServicePrincipal.ObjectId -Id $AppRole.Id

Write-Host "AdvancedHunting.Read.All permission assigned






# Update $MIGuid with your Logic App's Managed Identity Object ID

$MIGuid = ""
$MI = Get-AzureADServicePrincipal -ObjectId $MIGuid

$GraphAppId = "00000003-0000-0000-c000-000000000000"
$PermissionName1 = "SecurityEvents.Read.All"
$PermissionName2 = "SecurityActions.Read.All"

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"
$AppRole1 = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName1 -and $_.AllowedMemberTypes -contains "Application"}
New-AzureAdServiceAppRoleAssignment -ObjectId $MI.ObjectId -PrincipalId $MI.ObjectId `
    -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole1.Id

$AppRole2 = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName2 -and $_.AllowedMemberTypes -contains "Application"}
New-AzureAdServiceAppRoleAssignment -ObjectId $MI.ObjectId -PrincipalId $MI.ObjectId `
    -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole2.Id

Write-Host "Graph permissions assigned successfully!" -ForegroundColor Green



----------

HTTP Advanced Hunting Vulnerabilities
{
  "Query": "DeviceTvmSoftwareVulnerabilities | summarize TotalVulnerabilities = dcount(CveId), HighVulnerabilities = dcountif(CveId, VulnerabilitySeverityLevel == 'High'), CriticalVulnerabilities = dcountif(CveId, VulnerabilitySeverityLevel == 'Critical')"
}

Parse Vulnerabilities Response
{
  "type": "object",
  "properties": {
    "Results": {
      "type": "array"
    },
    "Stats": {
      "type": "object"
    }
  }
}


HTTP Advanced Hunting TopExposedDevices

{
  "Query": "DeviceTvmSoftwareVulnerabilities | summarize VulnerabilityCount = dcount(CveId), CriticalCount = dcountif(CveId, VulnerabilitySeverityLevel == 'Critical'), HighCount = dcountif(CveId, VulnerabilitySeverityLevel == 'High') by DeviceName, DeviceId | top 5 by VulnerabilityCount desc"
}

Parse TopExposedDevices Response

{
  "type": "object",
  "properties": {
    "Results": {
      "type": "array"
    },
    "Stats": {
      "type": "object"
    }
  }
}



{
  "type": "AdaptiveCard",
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "version": "1.4",
  "body": [
    {
      "type": "Container",
      "style": "emphasis",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "auto",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "🔐",
                  "size": "ExtraLarge",
                  "weight": "Bolder"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "Exposure Management - Identity Dashboard",
                  "weight": "Bolder",
                  "size": "Large",
                  "wrap": true
                },
                {
                  "type": "TextBlock",
                  "text": "Microsoft Entra Identity Security Report",
                  "spacing": "None",
                  "isSubtle": true,
                  "wrap": true
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "spacing": "Medium",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "auto",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "📊 Identity Secure Score",
                  "weight": "Bolder",
                  "size": "Medium",
                  "spacing": "None"
                },
                {
                  "type": "ColumnSet",
                  "spacing": "Small",
                  "columns": [
                    {
                      "type": "Column",
                      "width": "auto",
                      "items": [
                        {
                          "type": "TextBlock",
                          "text": "@{if(greater(outputs('Compose_Identity_Score_Data')?['identityMaxScore'], 0), formatNumber(div(mul(outputs('Compose_Identity_Score_Data')?['identityCurrentScore'], 100), outputs('Compose_Identity_Score_Data')?['identityMaxScore']), 'N2'), '0.00')}%",
                          "size": "ExtraLarge",
                          "weight": "Bolder",
                          "color": "Good"
                        }
                      ]
                    },
                    {
                      "type": "Column",
                      "width": "auto",
                      "verticalContentAlignment": "Bottom",
                      "items": [
                        {
                          "type": "TextBlock",
                          "text": "@{if(outputs('Compose_Previous_Identity_Score')?['hasPrevious'], concat(if(outputs('Compose_Previous_Identity_Score')?['isIncrease'], '▲ ', if(equals(outputs('Compose_Previous_Identity_Score')?['changePercentage'], 0), '', '▼ ')), formatNumber(if(less(outputs('Compose_Previous_Identity_Score')?['changePercentage'], 0), mul(outputs('Compose_Previous_Identity_Score')?['changePercentage'], -1), outputs('Compose_Previous_Identity_Score')?['changePercentage']), 'N2'), '%'), '')}",
                          "size": "Medium",
                          "weight": "Bolder",
                          "color": "@{if(outputs('Compose_Previous_Identity_Score')?['hasPrevious'], if(outputs('Compose_Previous_Identity_Score')?['isIncrease'], 'Good', 'Attention'), 'Default')}",
                          "spacing": "Small"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "TextBlock",
                  "text": "@{outputs('Compose_Identity_Score_Data')?['identityCurrentScore']} / @{outputs('Compose_Identity_Score_Data')?['identityMaxScore']} points",
                  "size": "Small",
                  "spacing": "None",
                  "isSubtle": true
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "TextBlock",
                  "text": "🏢 Tenant Score",
                  "weight": "Bolder",
                  "size": "Small",
                  "spacing": "None"
                },
                {
                  "type": "TextBlock",
                  "text": "@{if(greater(outputs('Compose_Identity_Score_Data')?['tenantMaxScore'], 0), formatNumber(div(mul(outputs('Compose_Identity_Score_Data')?['tenantCurrentScore'], 100), outputs('Compose_Identity_Score_Data')?['tenantMaxScore']), 'N2'), '0.00')}%",
                  "size": "Large",
                  "weight": "Bolder",
                  "spacing": "Small"
                },
                {
                  "type": "TextBlock",
                  "text": "@{outputs('Compose_Identity_Score_Data')?['tenantCurrentScore']} / @{outputs('Compose_Identity_Score_Data')?['tenantMaxScore']} points",
                  "size": "Small",
                  "spacing": "None",
                  "isSubtle": true
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "TextBlock",
                  "text": "📈 Statistics",
                  "weight": "Bolder",
                  "size": "Small",
                  "spacing": "None"
                },
                {
                  "type": "FactSet",
                  "spacing": "Small",
                  "facts": [
                    {
                      "title": "Controls:",
                      "value": "@{outputs('Compose_Identity_Score_Data')?['totalControls']}"
                    },
                    {
                      "title": "Licensed:",
                      "value": "@{outputs('Compose_Identity_Score_Data')?['licensedUsers']}"
                    },
                    {
                      "title": "Active:",
                      "value": "@{outputs('Compose_Identity_Score_Data')?['activeUsers']}"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "spacing": "Medium",
      "separator": true,
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "👥 Privileged Identities",
                  "weight": "Bolder",
                  "size": "Medium"
                },
                {
                  "type": "TextBlock",
                  "text": "Advanced Hunting KQL",
                  "size": "Small",
                  "isSubtle": true,
                  "spacing": "None"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "FactSet",
                  "spacing": "None",
                  "facts": [
                    {
                      "title": "🔴 Global Admins:",
                      "value": "@{if(greater(length(body('Parse_PrivilegedUsers_Response')?['Results']), 0), body('Parse_PrivilegedUsers_Response')?['Results'][0]?['TotalGlobalAdmins'], 0)}"
                    },
                    {
                      "title": "🟠 Security Admins:",
                      "value": "@{if(greater(length(body('Parse_PrivilegedUsers_Response')?['Results']), 0), body('Parse_PrivilegedUsers_Response')?['Results'][0]?['TotalSecurityAdmins'], 0)}"
                    },
                    {
                      "title": "🟡 Sensitive Users:",
                      "value": "@{if(greater(length(body('Parse_PrivilegedUsers_Response')?['Results']), 0), body('Parse_PrivilegedUsers_Response')?['Results'][0]?['TotalSensitive'], 0)}"
                    }
                  ]
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "FactSet",
                  "spacing": "None",
                  "facts": [
                    {
                      "title": "🔒 Disabled:",
                      "value": "@{if(greater(length(body('Parse_PrivilegedUsers_Response')?['Results']), 0), body('Parse_PrivilegedUsers_Response')?['Results'][0]?['TotalDisabled'], 0)}"
                    },
                    {
                      "title": "📊 Total Privileged:",
                      "value": "@{if(greater(length(body('Parse_PrivilegedUsers_Response')?['Results']), 0), body('Parse_PrivilegedUsers_Response')?['Results'][0]?['TotalPrivileged'], 0)}"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "spacing": "Medium",
      "separator": true,
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "🛡️ Vulnerabilities Overview",
                  "weight": "Bolder",
                  "size": "Medium"
                },
                {
                  "type": "TextBlock",
                  "text": "Threat & Vulnerability Management",
                  "size": "Small",
                  "isSubtle": true,
                  "spacing": "None"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "FactSet",
                  "spacing": "None",
                  "facts": [
                    {
                      "title": "📊 Total:",
                      "value": "@{if(greater(length(body('Parse_Vulnerabilities_Response')?['Results']), 0), body('Parse_Vulnerabilities_Response')?['Results'][0]?['TotalVulnerabilities'], 0)}"
                    },
                    {
                      "title": "⚠️ Exploitable:",
                      "value": "@{if(greater(length(body('Parse_Vulnerabilities_Response')?['Results']), 0), body('Parse_Vulnerabilities_Response')?['Results'][0]?['ExploitableVulnerabilities'], 0)}"
                    }
                  ]
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "separator": true,
              "items": [
                {
                  "type": "FactSet",
                  "spacing": "None",
                  "facts": [
                    {
                      "title": "🔴 Critical:",
                      "value": "@{if(greater(length(body('Parse_Vulnerabilities_Response')?['Results']), 0), body('Parse_Vulnerabilities_Response')?['Results'][0]?['CriticalVulnerabilities'], 0)}"
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "TextBlock",
          "text": "🖥️ Top Exposed Devices",
          "weight": "Bolder",
          "size": "Small",
          "spacing": "Medium"
        },
        {
          "type": "FactSet",
          "spacing": "Small",
          "facts": [
            {
              "title": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 0), concat('1. ', body('Parse_TopExposedDevices_Response')?['Results'][0]?['DeviceName']), '1. N/A')}",
              "value": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 0), concat(string(body('Parse_TopExposedDevices_Response')?['Results'][0]?['VulnerabilityCount']), ' vulns (', string(body('Parse_TopExposedDevices_Response')?['Results'][0]?['CriticalCount']), ' critical)'), '0 vulns')}"
            },
            {
              "title": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 1), concat('2. ', body('Parse_TopExposedDevices_Response')?['Results'][1]?['DeviceName']), '2. N/A')}",
              "value": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 1), concat(string(body('Parse_TopExposedDevices_Response')?['Results'][1]?['VulnerabilityCount']), ' vulns (', string(body('Parse_TopExposedDevices_Response')?['Results'][1]?['CriticalCount']), ' critical)'), '0 vulns')}"
            },
            {
              "title": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 2), concat('3. ', body('Parse_TopExposedDevices_Response')?['Results'][2]?['DeviceName']), '3. N/A')}",
              "value": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 2), concat(string(body('Parse_TopExposedDevices_Response')?['Results'][2]?['VulnerabilityCount']), ' vulns (', string(body('Parse_TopExposedDevices_Response')?['Results'][2]?['CriticalCount']), ' critical)'), '0 vulns')}"
            },
            {
              "title": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 3), concat('4. ', body('Parse_TopExposedDevices_Response')?['Results'][3]?['DeviceName']), '4. N/A')}",
              "value": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 3), concat(string(body('Parse_TopExposedDevices_Response')?['Results'][3]?['VulnerabilityCount']), ' vulns (', string(body('Parse_TopExposedDevices_Response')?['Results'][3]?['CriticalCount']), ' critical)'), '0 vulns')}"
            },
            {
              "title": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 4), concat('5. ', body('Parse_TopExposedDevices_Response')?['Results'][4]?['DeviceName']), '5. N/A')}",
              "value": "@{if(greater(length(body('Parse_TopExposedDevices_Response')?['Results']), 4), concat(string(body('Parse_TopExposedDevices_Response')?['Results'][4]?['VulnerabilityCount']), ' vulns (', string(body('Parse_TopExposedDevices_Response')?['Results'][4]?['CriticalCount']), ' critical)'), '0 vulns')}"
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "spacing": "Medium",
      "separator": true,
      "items": [
        {
          "type": "TextBlock",
          "text": "📋 Top 3 Recommendations",
          "weight": "Bolder",
          "size": "Medium"
        },
        {
          "type": "TextBlock",
          "text": "Highest impact improvements for Identity score",
          "size": "Small",
          "isSubtle": true,
          "spacing": "None"
        },
        {
          "type": "Container",
          "spacing": "Small",
          "items": [
            {
              "type": "ColumnSet",
              "columns": [
                {
                  "type": "Column",
                  "width": "auto",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "1️⃣",
                      "size": "Large",
                      "spacing": "None"
                    }
                  ]
                },
                {
                  "type": "Column",
                  "width": "stretch",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "@{if(greater(length(outputs('Compose_Top3_Recommendations')), 0), outputs('Compose_Top3_Recommendations')[0]?['title'], 'N/A')}",
                      "wrap": true,
                      "weight": "Bolder",
                      "size": "Small",
                      "spacing": "None"
                    },
                    {
                      "type": "TextBlock",
                      "text": "Gap: **@{if(greater(length(outputs('Compose_Top3_Recommendations')), 0), string(outputs('Compose_Top3_Recommendations')[0]?['gap']), '0')} points** (@{if(greater(length(outputs('Compose_Top3_Recommendations')), 0), string(outputs('Compose_Top3_Recommendations')[0]?['currentScore']), '0')}/@{if(greater(length(outputs('Compose_Top3_Recommendations')), 0), string(outputs('Compose_Top3_Recommendations')[0]?['maxScore']), '0')})",
                      "spacing": "None",
                      "size": "Small",
                      "isSubtle": true,
                      "wrap": true
                    }
                  ]
                }
              ]
            },
            {
              "type": "ColumnSet",
              "spacing": "Small",
              "columns": [
                {
                  "type": "Column",
                  "width": "auto",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "2️⃣",
                      "size": "Large",
                      "spacing": "None"
                    }
                  ]
                },
                {
                  "type": "Column",
                  "width": "stretch",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "@{if(greater(length(outputs('Compose_Top3_Recommendations')), 1), outputs('Compose_Top3_Recommendations')[1]?['title'], 'N/A')}",
                      "wrap": true,
                      "weight": "Bolder",
                      "size": "Small",
                      "spacing": "None"
                    },
                    {
                      "type": "TextBlock",
                      "text": "Gap: **@{if(greater(length(outputs('Compose_Top3_Recommendations')), 1), string(outputs('Compose_Top3_Recommendations')[1]?['gap']), '0')} points** (@{if(greater(length(outputs('Compose_Top3_Recommendations')), 1), string(outputs('Compose_Top3_Recommendations')[1]?['currentScore']), '0')}/@{if(greater(length(outputs('Compose_Top3_Recommendations')), 1), string(outputs('Compose_Top3_Recommendations')[1]?['maxScore']), '0')})",
                      "spacing": "None",
                      "size": "Small",
                      "isSubtle": true,
                      "wrap": true
                    }
                  ]
                }
              ]
            },
            {
              "type": "ColumnSet",
              "spacing": "Small",
              "columns": [
                {
                  "type": "Column",
                  "width": "auto",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "3️⃣",
                      "size": "Large",
                      "spacing": "None"
                    }
                  ]
                },
                {
                  "type": "Column",
                  "width": "stretch",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "@{if(greater(length(outputs('Compose_Top3_Recommendations')), 2), outputs('Compose_Top3_Recommendations')[2]?['title'], 'N/A')}",
                      "wrap": true,
                      "weight": "Bolder",
                      "size": "Small",
                      "spacing": "None"
                    },
                    {
                      "type": "TextBlock",
                      "text": "Gap: **@{if(greater(length(outputs('Compose_Top3_Recommendations')), 2), string(outputs('Compose_Top3_Recommendations')[2]?['gap']), '0')} points** (@{if(greater(length(outputs('Compose_Top3_Recommendations')), 2), string(outputs('Compose_Top3_Recommendations')[2]?['currentScore']), '0')}/@{if(greater(length(outputs('Compose_Top3_Recommendations')), 2), string(outputs('Compose_Top3_Recommendations')[2]?['maxScore']), '0')})",
                      "spacing": "None",
                      "size": "Small",
                      "isSubtle": true,
                      "wrap": true
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "spacing": "Small",
      "separator": true,
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "📅 Generated: @{formatDateTime(variables('Timestamp'), 'MMM dd, yyyy HH:mm')} UTC",
                  "size": "Small",
                  "isSubtle": true,
                  "wrap": true,
                  "spacing": "None"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "🔄 Score updated: @{formatDateTime(outputs('Compose_Identity_Score_Data')?['createdDateTime'], 'MMM dd, yyyy HH:mm')} UTC",
                  "size": "Small",
                  "isSubtle": true,
                  "wrap": true,
                  "spacing": "None"
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "📋 View Full Recommendations",
      "url": "https://security.microsoft.com/securescore?viewid=overview",
      "style": "positive"
    },
    {
      "type": "Action.OpenUrl",
      "title": "🔐 Identities Dashboard",
      "url": "https://security.microsoft.com/identities/dashboard?tid=9d8488e4-e94c-4e13-be3c-f8bcfdbf80a0"
    }
  ]
}

---

<img width="176" height="356" alt="image" src="https://github.com/user-attachments/assets/17aae445-d5b3-46fa-a57b-04885a243704" />

