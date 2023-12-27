Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName "Concierge Subscription"
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-b255d113-de6c-42eb-896f-569bea446568
New-AzResourceGroupDeployment `
   -environmentType 'nonprod' `
   -TemplateFile main.bicep 




