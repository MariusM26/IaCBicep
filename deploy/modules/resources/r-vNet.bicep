param environmentType string
param location string
param addressPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-${environmentType}-${location}'
  location: location
  properties: {
    privateEndpointVNetPolicies: 'Disabled'
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
  dependsOn: [
    resourceGroup()
  ]
}

output vNetName string = virtualNetwork.name
output vNetId string = virtualNetwork.id
