@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment in which the deployment is done.)')
param environmentType string

var retentionInDays int = 30
var location string = 'WestEurope'
var workspaceName string = 'la-${environmentType}'

module workspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'workspaceDeployment'
  scope: resourceGroup()
  params: {
    // Required parameters
    name: workspaceName
    // Non-required parameters
    location: location
    dataRetention: retentionInDays
    dailyQuotaGb: 1
    tags: {
      Environment: environmentType
      Role: 'DeploymentValidation'
    }
  }
}
