@description('The environment in which the deployment is done.)')
param environmentType string
param location string

@description('The name of the Azure Container Registry (container registry + app + env)')
var containerRegistryName string = 'crmarad${environmentType}'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: containerRegistryName
  location: location
  dependsOn: [
    resourceGroup()
  ]
  properties: {
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    policies: {
      exportPolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    adminUserEnabled: true
  }
  sku: {
    name: 'Standard'
  }
}
