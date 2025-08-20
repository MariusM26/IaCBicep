@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment in which the deployment is done.)')
param environmentType string
param resourceGroupName string

@description('The base location for the shared resources group.')
var baseLocation string = 'WestEurope'

@description('The name of the shared resources group.')
var rgName string = 'rg-${resourceGroupName}-${environmentType}'

targetScope = 'subscription'

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'resourceGroupDeployment'
  params: {
    name: rgName
    tags: {
      Environment: environmentType
      Role: 'DeploymentValidation'
    }
    location: baseLocation
  }
}
