Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName "Concierge Subscription"
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-e8b26bc6-e47c-4495-a055-80a3c0a159d8
New-AzResourceGroupDeployment -TemplateFile main.bicep 