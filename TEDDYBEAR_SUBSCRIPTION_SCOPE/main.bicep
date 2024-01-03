// DEPLOYS RESOURCE FOR CUSTOM POLICY - CREATE ROLE DEFINITION RESOURCES TO DENY DEPLOYMENT OF STANDARD F & G SERIES VMs IN SUBSCRIPTION
// DEPLOYS RESOURCE AND A VNET FROM MODULE TO THE RESOURCE NEW RESOURCE GROUP.

targetScope = 'subscription'

param location string = deployment().location
param virtualNetworkName string 
param virtualNetworkAddressPrefix string

var policyDefinitionName = 'DenyFandGSeriesVMs' 
var policyAssignmentName = 'DenyFandGSeriesVMs'
var resourceGroupName = 'ToyNetworking'


resource policyDefintion 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyDefinitionName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute.virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/virtualMachines.sku.name'
                like: 'Standard_G*'
              }
              {
                field: 'Microsoft.Compute/virtualMachines.sku.name'
                like: 'Standard_F*'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'Deny'
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: policyAssignmentName
  properties: {
    policyDefinitionId: policyDefintion.id
  }
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'virtualNetwork'
  params: {
    virtualNetworkAddressPrefix: virtualNetworkName
    virtualNetworkName: virtualNetworkAddressPrefix
  }
}
