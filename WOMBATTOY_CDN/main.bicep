@description('Azure datacenter/region where to deploy resources from.')
param location string = 'westus3'

@description('Name of the web application.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

param appServicePlanName string = 'toy-product-lauch-plan'

@description('Sku for the webApp.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true


module app 'modules/app.bicep' = {
  name: 'toy-launch-app'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
  }
}

module cdn 'modules/cdn.bicep' = if(deployCdn) {
  name: 'toy-launch-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

// OUTPUT
output appServiceHostName string = app.outputs.appServiceAppHostName
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
