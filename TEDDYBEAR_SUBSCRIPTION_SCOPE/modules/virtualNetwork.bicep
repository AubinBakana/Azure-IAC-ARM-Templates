// A MODULE FOR A VIRTUAL NETWORK.

param virtualNetworkName string
param virtualNetworkAddressPrefix string 


// RESOURCES
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
  }
}
