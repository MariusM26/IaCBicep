@description('The environment in which the deployment is done.)')
param environmentType string

@description('The name of the Azure Container Registry (container registry + app + env)')
var containerRegistryName string = 'crmarad${environmentType}'

targetScope = 'subscription'

resource commonRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-common'
  location: 'WestEurope'
  tags: {
    Environment: 'dev'
  }
}

module registry 'br/public:avm/res/container-registry/registry:0.9.1' = {
  name: 'containerRegistryDeployment'
  scope: commonRG
  params: {
    // Required parameters
    name: containerRegistryName
    // Non-required parameters
    acrAdminUserEnabled: true
    acrSku: 'Standard'
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    exportPolicyStatus: 'enabled'
    softDeletePolicyDays: 7
    softDeletePolicyStatus: 'disabled'
    tags: {
      Environment: 'Dev'
      Role: 'DeploymentValidation'
    }
  }
}

module vNet '../resources/r-vNet.bicep' = {
  scope: commonRG
  params: {
    environmentType: environmentType
  }
}
