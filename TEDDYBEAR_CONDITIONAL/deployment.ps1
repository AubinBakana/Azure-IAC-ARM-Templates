Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName 'Concierge Subscription'
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-3488675e-2a72-49f8-9a0b-53233d3dc487
New-AzResourceGroupDeployment -TemplateFile .\main.bicep