Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName 'Concierge Subscription'
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-6e346869-e217-4347-92b6-25973ee23101
New-AzResourceGroupDeployment -TemplateFile .\main.bicep 
