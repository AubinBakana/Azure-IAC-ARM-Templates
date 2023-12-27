@allowed([
  'dev'
  'test' 
  'prod'
])
@description('Name of the environment where to deploy the application. Must be dev test or prod')
param environmentName string = 'dev'

@minLength(5)
@maxLength(30)
@description('Name of the app solution.')
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@minValue(1)
@maxValue(10)
@description('Computer resources count. How many servers in the farm?')
param appServicePlanInstantCount int = 1

@description('The name and tier to specify SKU for the application computer resources')
param appServicePlanSku object 

@description('The name of the Azure Region in which the resource should be deployed')
param location string = 'westus3'

@description('SQL Server Login for the administrator.')
@secure()
param sqlServerAdministratorLogin string

@description('Password for SQL Server Administrator.')
@secure()
param sqlServerAdministratorPassword string

@secure()
param sqlDatabaseSku object


var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-app' 
var sqlDatabaseName = 'Employees'


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstantCount
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


resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}
