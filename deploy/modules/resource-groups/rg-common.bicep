@description('The environment in which the deployment is done.)')
param environmentType string
param location string = 'WestEurope'

targetScope = 'subscription'

resource commonRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-common'
  location: 'WestEurope'
  tags: {
    Environment: 'dev'
  }
}

module registry '../resources/r-containerRegistry.bicep' = {
  scope: commonRG
  params: {
    location: location
    environmentType: environmentType
  }
}
