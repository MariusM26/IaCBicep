@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment in which the deployment is done.)')
param environmentType string = 'dev'
param location string = 'WestEurope'
param workspaceName string = 'laWorkspace-${environmentType}-${location}'
param retentionInDays int = 30

module workspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'workspaceDeployment'
  scope: resourceGroup()
  params: {
    name: workspaceName
    location: location
    dataRetention: retentionInDays
    dailyQuotaGb: 1
    tags: {
      Environment: environmentType
      Role: 'DeploymentValidation'
    }
  }
}

output logAnalyticsId string = workspace.outputs.resourceId
