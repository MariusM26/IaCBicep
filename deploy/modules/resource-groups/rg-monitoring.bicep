param location string
param environmentType string

targetScope = 'subscription'

resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-monitoring'
  location: location
}

module laWorkspace '../resources/analytics/r-logAnalytics.bicep' = {
  scope: monitoringRG
  params: {
    environmentType: environmentType
  }
}
