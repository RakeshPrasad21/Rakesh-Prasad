Connect-AzureAD
$MIGuid = "<Enter your managed identity guid here>"
$SubscriptionId = "<Enter your subsciption id here>"
$ResourceGroup = "<Enter your resource group here>"
$MI = Get-AzureADServicePrincipal -ObjectId $MIGuid
$RoleName = "Microsoft Sentinel Reader"
New-AzRoleAssignment -ObjectId $MIGuid -RoleDefinitionName $RoleName -Scope /subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup


Connect-AzureAD
$MIGuid = "<Enter your managed identity guid here>"
$SubscriptionId = "<Enter your subsciption id here>"
$ResourceGroup = "<Enter your resource group here>"
$MI = Get-AzureADServicePrincipal -ObjectId $MIGuid
$RoleName = "Microsoft Sentinel Reader"
New-AzRoleAssignment -ObjectId $MIGuid -RoleDefinitionName $RoleName -Scope /subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup


Connect-AzureAD
$MIGuid = "<Enter your managed identity guid here>"
$SubscriptionId = "<Enter your subsciption id here>"
$ResourceGroup = "<Enter your resource group here>"
$MI = Get-AzureADServicePrincipal -ObjectId $MIGuid
$RoleName = "Log Analytics Reader"
New-AzRoleAssignment -ObjectId $MIGuid -RoleDefinitionName $RoleName -Scope /subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup
