// MODULE: Web application module.

// Declaring variables and parameters.
@description('Name of the app service plan: Compute resource for the webapp')
param appServicePlanName string

@description('Azure datacenter/region where to deploy resource from')
param location string

@description('Name for compute resource SKU.')
param appServicePlanSkuName string

@description('Name for the webapp resource.')
param appServiceAppName string


// DEFINE RESOURCES
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}


// OUPUTS
@description('Defaut hostname for the app.')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName


