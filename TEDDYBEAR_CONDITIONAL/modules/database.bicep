// Database module. Using conditional deployment to ensure auditing resources are created only in production.

// Declaring parameters & variables.
@description('The Azure Region where resources should be deployed.')
param location string

@description('SQL Server Administrator login/username.')
@secure()
param sqlServerAdministratorLogin string

@description('SQL Server Administrator\'s password.')
@secure()
param sqlServerAdministratorLoginPassword string

@description('Compute resource sku and name for SQL Server')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('Name of Storage for SQL monitoring')
param sqlStorageAccountSkuName string = 'Standard_LRS'

@description('Name of the deployment environment. Enter either \'Development\' or \'Production\'.')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Development' 


var sqlServerName = 'teddy${location}${uniqueString(resourceGroup().id)}' 
var sqlDatabaseName = 'TeddyBear'
var auditEnabled = environmentName == 'Production'
var auditStorageAccountName = take('bearaudit${location}${uniqueString(resourceGroup().id)}', 24) 


// Resources
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource auditStorageaccount 'Microsoft.Storage/storageAccounts@2021-09-01' = if(auditEnabled) {
  name: auditStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: sqlStorageAccountSkuName
  }
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2021-11-01' = if(auditEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: (environmentName == 'Production') ? auditStorageaccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: (environmentName == 'Production') ? listkeys(auditStorageaccount.id, auditStorageaccount.apiVersion).keys[0].value : ''
  }
}

// Outputs
output serverName string = sqlServer.name
output location string =  location
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName


