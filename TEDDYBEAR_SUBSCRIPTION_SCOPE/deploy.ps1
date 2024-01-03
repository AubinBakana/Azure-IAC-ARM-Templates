Connect-AzAccount 
$context = Get-AzSubscription -SubscriptionName 'Top Secret Subscription'
$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "sub-scope-deny-FandGSeries-$today"
$virtualNetworkName = 'rnd-vnet-111'
$virtualNetworkAddressPrefix = '10.0.0.0/24'
Set-AzContext $context

New-AzSubscriptionDeployment `
    -Name $deploymentName `
    -Location westus `
    -TemplateFile $templateFile
    -virtualNetworkName $virtualNetworkName
    -virtualNetworkAddressPrefix $virtualNetworkAddressPrefix
