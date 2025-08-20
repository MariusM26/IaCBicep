param environmentType string
param location string = 'WestEurope'

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'virtualNetworkDeployment'
  scope: resourceGroup()
  params: {
    // Required parameters
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: 'vnet-${environmentType}-${location}'
    // Non-required parameters
    location: location
  }
}
