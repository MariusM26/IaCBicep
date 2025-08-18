@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment in which the deployment is done.)')
param environmentType string

@description('The base location for the shared resources group.')
var baseLocation string = 'WestEurope'

@description('The name of the shared resources group.')
var resourceGroupName string = 'rg-shared-platform-${environmentType}'

@description('The name of the Azure Container Registry (container registry + app + env)')
var containerRegistryName string = 'crmarad${environmentType}'

targetScope = 'subscription'

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'resourceGroupDeployment'
  params: {
    name: resourceGroupName
    tags: {
      Environment: 'Dev'
      Role: 'DeploymentValidation'
    }
    location: baseLocation
  }
}

resource outputRG 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

module registry 'br/public:avm/res/container-registry/registry:0.9.1' = {
  name: 'containerRegistryDeployment'
  scope: outputRG
  params: {
    // Required parameters
    name: containerRegistryName
    // Non-required parameters
    acrAdminUserEnabled: true
    acrSku: 'Standard'
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    exportPolicyStatus: 'enabled'
    location: baseLocation
    softDeletePolicyDays: 7
    softDeletePolicyStatus: 'disabled'
    tags: {
      Environment: 'Dev'
      Role: 'DeploymentValidation'
    }
  }
}
