param environmentType string
param location string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-${environmentType}-${location}'
  location: location
  dependsOn: [
    resourceGroup()
  ]

  properties: {
    privateEndpointVNetPolicies: 'Disabled'
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}
