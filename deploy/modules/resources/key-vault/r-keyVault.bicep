// ==============================================================
// Bicep template for a Key Vault with dedicated Private Endpoint
// ==============================================================

@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

@maxLength(18)
@description('Short keyword for vault business context used in resource naming.')
param keyword string

@description('Resource ID of the Private DNS zone to link to the private endpoint.')
param privateDnsZoneResourceId string

@description('Resource ID of the subnet where the Key Vault private endpoint will be created.')
param subnetResourceId string

@description('The workspace id to which the logs and metrics should be sent to.')
param logAnalyticsWorkspaceId string

@description('Purge Protection prevents permanent deletion of soft-deleted vault/objects until retention period ends. \n\r For a production deployment, the value is implicitly true.')
param enablePurgeProtection bool = false

@description('Soft Delete allows recovery of deleted vault contents during the retention period. \n\r For a production deployment, the value is implicitly true.')
param enableSoftDelete bool = false

@minValue(7)
@maxValue(90)
@description('Number of days to retain soft-deleted items. \n\r For a production deployment, the value is implicitly 90 days.')
param softDeleteRetentionInDays int = 7

@description('Allow trusted Microsoft services to bypass Key Vault firewall rules.')
param bypassTrustedServices bool = true

@allowed(['Allow', 'Deny'])
@description('Block public traffic.')
param defaultNetworkAction string = 'Deny'

module diagnosticSettingsCategories '../../common/diagnosticSettingsCategories.bicep' = {
  params: {
    ErrorsEnabled: true
    BasicMetricsEnabled: true
  }
}

var isProduction = environmentType == 'prod'

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'KeyVaultDeployment'
  params: {
    name: 'kv${environmentType}${keyword}'
    location: resourceGroup().location
    // Environment-based
    enablePurgeProtection: isProduction ? true : enablePurgeProtection
    enableSoftDelete: isProduction ? true : enableSoftDelete
    softDeleteRetentionInDays: isProduction ? 90 : softDeleteRetentionInDays
    // Defaults
    enableRbacAuthorization: true
    sku: 'standard'
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneResourceId
            }
          ]
        }
        subnetResourceId: subnetResourceId
        service: 'vault'
      }
    ]
    // Firewall
    networkAcls: {
      bypass: bypassTrustedServices ? 'AzureServices' : 'None'
      defaultAction: defaultNetworkAction
    }
    diagnosticSettings: [
      {
        name: '${logAnalyticsWorkspaceId}-customDiagnosticSettings'
        workspaceResourceId: logAnalyticsWorkspaceId
        logCategoriesAndGroups: diagnosticSettingsCategories.outputs.logsCategories
        metricCategories: diagnosticSettingsCategories.outputs.metricsCategories
        // To be configured if logs retention is desired
        storageAccountResourceId: null
      }
    ]
    tags: {
      Environment: environmentType
    }
  }
}

output name string = keyVault.outputs.name
output id string = keyVault.outputs.resourceId
