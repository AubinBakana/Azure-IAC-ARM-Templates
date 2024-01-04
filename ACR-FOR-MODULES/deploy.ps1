Connect-AzAccount
$context = Get-AzSubscription -SubscriptionName "Concierge Subscription"
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-a4509bfc-7fa4-4659-9bfa-f5a0fb71ee52
New-AzContainerRegistry `
    -Name storemodules040124 `
    -Sku 'Basic' `
    -Location 'westus'

Get-AzContainerRegistryRepository -RegistryName storemodules040124 | FT

# The following is a bicep code

bicep publish website.bicep `
--target 'br:storemodules040124.azurecr.io/website:v1'

bicep publish cdn.bicep `
  --target 'br:storemodules040124.azurecr.io/cdn:v1'

# DEPLOY RESOURCES
bicep build main.bicep

New-AzResourceGroupDeployment -TemplateFile main.bicep

