// A TOY COMPANY WEBSITE'S PROJECT - DEPLOYS RESOURCES FOR PRODUCTS MANUAL
// INCLUDES IDENTITY AND ACCESS, ROLE ASSIGNMENT, SECURITY, MONITORING, & ALL REQUIRED RESOURCES FOR FRONT AND BACK END.

// DECLARING PARAMETERS AND VARIABLES.
@description('Datacent or region for the resource deployment.')
param location string = resourceGroup().location

@description('Administrator login: username.')
@secure()
param sqlAdministratorLogin string

@secure()
@description('Administrator login: password.')
param sqlAdministratorLoginPassword string

@description('Name of the resource Managed Identity.')
param managedIdentityName string = take('managed-identity-products-manual-toy-website-${uniqueString(resourceGroup().id)}', 64)

@description('Identity role definition to scope user\'s access level.')
param roleDefinitionId string

@description('Name for the appServiceApp resource')
param productsWebsiteName string = 'webSite${uniqueString(resourceGroup().id)}'

@allowed([
  'nonProduction'
  'production'
])
@description('Resource deployment depends on the environment. Choose \'production\' for Production or \'nonProduction\' for Non-Production  ')
param environmentType string = 'nonProduction'

var appServiceName = 'hostingplan${uniqueString(resourceGroup().id)}'
var sqlServerName = 'toywebsite${uniqueString(resourceGroup().id)}'
var storageAccountName = 'toywebsite${uniqueString(resourceGroup().id)}'
var databaseName = 'ToyCompanyWebsite'
var blobContainerNames = [
  'productsSpecs'
  'productsManuals'
]
var environmentConfigurationMap = {
  production: {
    appService: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    storageAccount: {
      sku: {
        name: 'GRS'
      } 
    }
    sqlDatabase: {
      sku: {
        name: 'S1'
      }
    }
  } 
  nonProduction: {
    appService: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'LRS'
      } 
    }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  } 
}


// RESOURCES
resource productsManualStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: environmentConfigurationMap[environmentType].storageAccount.sku
  } 
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'

    resource containers 'containers' = [for blobContainerName in blobContainerNames: {
      name: blobContainerName
    }]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlDabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${sqlServer.name}-${databaseName}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlFirewallRules 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  name: '${sqlServer.name}-AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource productsWebsiteAppService 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServiceName
  location: location
  sku: {
    name:environmentConfigurationMap[environmentType].appService.sku.name
    capacity: environmentConfigurationMap[environmentType].appService.capacity
  }
}

resource productsWebiteAppServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: productsWebsiteName
  location: location
  properties: {
    serverFarmId: productsWebsiteAppService.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: productsWebsiteAppInsights.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${productsManualStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(productsManualStorageAccount.id, productsManualStorageAccount.apiVersion).keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${productsWebsiteUserAssignedIdentity.id}': {}
    }
  }
}

resource productsWebsiteUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource productsWebsiteManagedIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleDefinitionId, resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: productsWebsiteUserAssignedIdentity.properties.principalId
  }
}

resource productsWebsiteAppInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}





