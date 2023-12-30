// Creates a database in mulitple locations using variable loops & module. Each resource to be deployed in its own VNET as per company policy

// Declare parameters & variables.
@description('A list of Azure regions in which resources would be deployed')
param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

@description('SQL Server Administrator Login/Username')
@secure()
param sqlServerAdministratorLogin string

@description('SQL Server Administrator login Password')
@secure()
param sqlServerAdministratorLoginPassword string

@description('Range of IP to use for virtual network')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('Subnets for the VNet')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }

}] 


// RESOURCES 
module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2021-08-01' = [for location in locations: {
    name: 'teddy-${location}'
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [
          virtualNetworkAddressPrefix
        ]
      }
      subnets: subnetProperties
    }
  }

]

// Outputs
output serverInfor array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]  
