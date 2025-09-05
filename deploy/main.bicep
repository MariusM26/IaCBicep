param location string = 'WestEurope'
param env string = 'dev'

targetScope = 'subscription'

module resourceGroupMonitoring 'modules/resource-groups/rg-monitoring.bicep' = {
  scope: subscription()
  params: {
    environmentType: env
    location: location
  }
}

module resourceGroupNetwork 'modules/resource-groups/rg-network.bicep' = {
  scope: subscription()
  params: {
    location: location
    environmentType: env
  }
}

module resourceGroupBackoffice 'modules/resource-groups/rg-backoffice.bicep' = {
  scope: subscription()
  params: {
    location: location
    subnetId: resourceGroupNetwork.outputs.appServiceSubnetId
  }
}

module resourceGroupCommon 'modules/resource-groups/rg-common.bicep' = {
  scope: subscription()
  params: {
    environmentType: env
  }
}
