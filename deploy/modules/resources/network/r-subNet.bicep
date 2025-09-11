param vNetName string
param resourceName string
param subNetAddressPrefix string
param networkSecurityGroupId string = ''
param privateEndpointNetworkPolicies string = 'Enabled' // Disabled for Private Endpoints

@description('Array of subnet delegations. Empty array for no delegations.')
param delegations array = []

resource parentVNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vNetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: 'snet-${resourceName}'
  parent: parentVNet
  properties: {
    addressPrefix: subNetAddressPrefix
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    delegations: delegations
  }
}

output subnetId string = subnet.id
