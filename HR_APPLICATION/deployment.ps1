Connect-AzAccount 
$context = Get-AzSubscription -SubscriptionName 'Concierge Subscription'
Set-AzContext $context
Set-AzDefault -ResourceGroupName learn-9d11214a-f761-47f3-9e6e-d041a2dec296
New-AzResourceGroupDeployment `
  -TemplateFile .\main.bicep `
  -TemplateParameterFile .\main.parameters.json 


$keyVaultName = 'keyvault-hrapp-1225'
$login = Read-Host "Enter the login name" -AsSecureString
$password = Read-Host "Enter the password" -AsSecureString

New-AzKeyVault -VaultName $keyVaultName -Location westus3 -EnabledForTemplateDeployment
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorLogin' -SecretValue $login
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorPassword' -SecretValue $password 

(Get-AzKeyVault -Name $keyVaultName).ResourceId