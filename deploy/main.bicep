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

module resourceGroupBackoffice 'modules/resource-groups/rg-backoffice.bicep' = {
  scope: subscription()
  params: {
    location: location
  }
}

module resourceGroupCommon 'modules/resource-groups/rg-common.bicep' = {
  scope: subscription()
  params: {
    environmentType: env
  }
}
