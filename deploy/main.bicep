@description('The base location for the first resource group cluster.')
var resourceGroupLocation string = 'WestEurope'

targetScope = 'subscription'

resource mainResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-backoffice-dev'
  location: resourceGroupLocation
}
