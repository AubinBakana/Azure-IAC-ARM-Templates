// DEPLOY RESOURCES FOR THE LAUNCH OF A NEW FLIGHT TEST DRONE. 
// Using parent syntax and embedding child resources to the parent


// DECLARING VARIABLES
@description('Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('Name of the CosmosDB account.')
param cosmosDBAccountName string = 'toyrnd${uniqueString(resourceGroup().id)}'

@description('CosmosDB database throughput')
param cosmosDBDatabaseThroughput int = 400

@description('Name of the storage account')
param storageAccountName string

var cosmosDBDatabaseName = 'FlightTest'
var cosmosDBContainerName = 'FlightTest'
var cosmosDBContainerPartionKey = '/droneId'
var logAnalyticsWorkspaceName = 'ToyLogs'
var cosmosDBAccountDiagnosticSettingsName = 'route-logs-to-analytics'
var storageAccountBlobDiagnosticsSettingsName = 'route-logs-to-log-analytics'


// RESOURCES:
resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
  name: cosmosDBDatabaseName
  parent: cosmosDBAccount
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartionKey
          ]
        }
      }
      options: {}
    }    
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing =  {
  name: logAnalyticsWorkspaceName
}

resource cosmosDBAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: cosmosDBAccount
  name: cosmosDBAccountDiagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName

  resource blobServices 'blobServices' existing = {
    name: 'default'
  }
}

resource storageAccountBlobDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: storageAccount::blobServices
  name: storageAccountBlobDiagnosticsSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }      
    ]
  }
}


