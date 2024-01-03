$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "deploymentscript-$today"
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -Name $deploymentName `
  -TemplateFile $templateFile