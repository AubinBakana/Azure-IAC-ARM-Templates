param location string = 'westus3'
param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'
@allowed([
  'prod'
  'nonprod'
])
param environmentType string

var storageAccountSku = (environmentType == 'nonprod') ? 'Standard_LRS': 'Premium_GRS'


resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
  }
}

module appService 'modules/appService.bicep'= {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

output appServiceAppHostname string = appService.outputs.appServiceAppHostName 




