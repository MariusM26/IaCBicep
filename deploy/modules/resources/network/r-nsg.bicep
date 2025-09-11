import { appServiceRules } from '../../common/service-rules/appServiceRules.bicep'
import { privateEndpointRules } from '../../common/service-rules/privateEndpointRules.bicep'
import { storageRules } from '../../common/service-rules/storageRules.bicep'
import { serviceBusRules } from '../../common/service-rules/serviceBusRules.bicep'
import { containerRegistryRules } from '../../common/service-rules/containerRegistryRules.bicep'

// User input parameters
@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

@description('The region in which the Network Security Group is deployed.')
param location string = resourceGroup().location

@allowed([
  'appservice'
  'privateendpoint'
  'storage'
  'servicebus'
  'containerregistry'
])
@description('The type of Network Security Group rules to apply.')
param nsgType string

// Resources input parameters
@description('The workspace id to which the logs and metrics should be sent to.')
param logAnalyticsWorkspaceId string

// Local variables
var allRules = {
  appservice: appServiceRules
  privateendpoint: privateEndpointRules
  storage: storageRules
  servicebus: serviceBusRules
  containerregistry: containerRegistryRules
}
var deploymentName = 'nsgdpl-${environmentType}-${location}'
var nsgName = 'nsg-${environmentType}-${nsgType}-001'

// Referenced resources
module diagnosticSettingsCategories '../../common/diagnosticSettingsCategories.bicep' = {
  params: {
    ErrorsEnabled: true
  }
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.1' = {
  name: deploymentName
  params: {
    diagnosticSettings: [
      {
        logCategoriesAndGroups: diagnosticSettingsCategories.outputs.logsCategories
        name: '${logAnalyticsWorkspaceId}-customDiagnosticSettings'
        storageAccountResourceId: null // To be configured if extra logs retention is desired
        workspaceResourceId: logAnalyticsWorkspaceId
      }
    ]
    location: location
    name: nsgName
    securityRules: allRules[nsgType]
    tags: {
      Environment: environmentType
    }
  }
}

output resourceId string = networkSecurityGroup.outputs.resourceId
