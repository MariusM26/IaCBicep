// User input parameters
@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

@description('The region in which the Virtual Network is deployed.')
param location string = resourceGroup().location

// Resources input parameters
@description('The workspace id to which the logs and metrics should be sent to.')
param logAnalyticsWorkspaceId string

param networkSecurityGroupId string

// Local variables
var deploymentName = 'vnetdpl-${environmentType}-${location}'
var vNetCIDR = '10.20.0.0/16'
var vNetName = 'vnet-${environmentType}-${location}-001'
var subNetName_SQL = 'snet-sql-backoffice-${environmentType}-${location}'
var subNetCIDR_SQL = '10.20.10.0/24'

module diagnosticSettingsCategories '../../common/diagnosticSettingsCategories.bicep' = {
  params: {
    ErrorsEnabled: true
    BasicMetricsEnabled: true
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: deploymentName
  params: {
    addressPrefixes: [
      vNetCIDR
    ]
    diagnosticSettings: [
      {
        logCategoriesAndGroups: diagnosticSettingsCategories.outputs.logsCategories
        metricCategories: diagnosticSettingsCategories.outputs.metricsCategories
        name: '${logAnalyticsWorkspaceId}-customDiagnosticSettings'
        storageAccountResourceId: null // To be configured if extra logs retention is desired
        workspaceResourceId: logAnalyticsWorkspaceId
      }
    ]
    dnsServers: [
      '10.0.1.4'
      '10.0.1.5'
    ]
    flowTimeoutInMinutes: 20
    location: location
    name: vNetName
    subnets: [
      {
        addressPrefix: subNetCIDR_SQL
        name: subNetName_SQL
        privateEndpointNetworkPolicies: 'Disabled' // Disabled for subnets with private endpoints
        networkSecurityGroupResourceId: networkSecurityGroupId
      }
    ]
    tags: {
      Environment: environmentType
    }
  }
}

output vNetName string = virtualNetwork.outputs.name
output vNetId string = virtualNetwork.outputs.resourceId
output subNetId_sql string = virtualNetwork.outputs.subnetResourceIds[0] // Be sure this is SQL subnet
