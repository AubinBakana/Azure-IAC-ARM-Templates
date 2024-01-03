Connect-AzAccount 
$context Get-AzSubscription -SubscriptionName 'Top Secret Subscription'
$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "sub-scope-deny-FandGSeries-$today"
Set-AzContext $context

New-AzSubscriptionDeployment `
    -Name $deploymentName `
    -Location westus `
    -TemplateFile $templateFile
