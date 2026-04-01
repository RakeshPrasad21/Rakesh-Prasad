
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

<img width="176" height="356" alt="image" src="https://github.com/user-attachments/assets/17aae445-d5b3-46fa-a57b-04885a243704" />

