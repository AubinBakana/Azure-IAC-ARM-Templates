# To simulate an existing resource, we quickly create a management group with powershell
New-AzManagementGroupDeployment `
    -GoupId 'SecretRnD' `
    -DisplayName 'Secret RnD Projects'

    
Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName "Secret RnD Projects"
Set-AzContext $context
$managmentGroupID = 'SecretRnD'
$today = Get-Date -Format "MM-dd-yyyy"
$deploymentName = "deny-FandGVMs-mg-scope-policy-$today"
$templateFile = '.\main.bicep'

New-AzManagementGroupDeployment `
    -Name $deploymentName
    -ManagemenGroupId $managmentGroupID
    -location 'westus'
    -templateFile $templateFile