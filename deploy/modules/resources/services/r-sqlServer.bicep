// =============================================================================
// Bicep template for an SQL Server and Database with dedicated Private Endpoint
// =============================================================================

// User input parameters
@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

@description('The region in which the SQL Server is deployed.')
param location string = resourceGroup().location

// Resources input parameters
@description('Azure AD admin objectId (user/group/app).')
param aadObjectId string
// bicep this //// create rbac based on the bicepconfig import

@description('The workspace id to which the logs and metrics should be sent to.')
param logAnalyticsWorkspaceId string

@description('Resource ID of the Private DNS zone to link to the private endpoint.')
param privateDnsZoneResourceId string

@description('Required for the weekly vulnerability assessments done for the SQL Server.')
param storageAccountId string

@description('Required for the SQL Server Private Endpoint definition.')
param subNetId string

@description('The region`s Virtual Network name.')
param vNetName string

// Local variables
var deploymentName = 'sqldpl-backoffice-${environmentType}-${location}'
var serverAdminUsername = 'marasoftuser'
var sqlDatabaseName = 'sqldb-backoffice-${environmentType}'
var sqlPrivateDnsZone = 'privatelink${environment().suffixes.sqlServerHostname}'
var sqlServerName = 'sqlsrv-backoffice-${environmentType}'

// Referenced resources
module diagnosticSettingsCategories '../../common/diagnosticSettingsCategories.bicep' = {
  params: {
    ErrorsEnabled: true
    BasicMetricsEnabled: true
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vNetName
}

/* -------------------- SQL Server + Database -------------------- */
module sqlServer 'br/public:avm/res/sql/server:0.20.2' = {
  name: deploymentName
  params: {
    name: sqlServerName
    administrators: {
      administratorType: 'ActiveDirectory' // This ensures that the identity sources is Entra ID
      azureADOnlyAuthentication: true // This will disable classic SQL auth and enables token-based auth
      login: serverAdminUsername
      principalType: 'Group' // This will set an Entra group as the administrator
      sid: aadObjectId
      tenantId: tenant().tenantId
    }
    connectionPolicy: 'Redirect'
    keys: [
      {
        serverKeyType: 'ServiceManaged'
      }
    ]
    // ============================================= Should we configure an encryption CMK? or use the default MMK (Microsoft Managed Key)
    // customerManagedKey: {
    //   autoRotationEnabled: true
    //   keyName: '<keyName>'
    //   keyVaultResourceId: '<keyVaultResourceId>'
    //   keyVersion: '<keyVersion>'
    // }
    databases: [
      {
        availabilityZone: -1 // No specific availability zone
        backupLongTermRetentionPolicy: {
          weeklyRetention: 'P6W' // Do weekly backups and retain them for 6 weeks
        }
        backupShortTermRetentionPolicy: {
          retentionDays: 7 // Implicit daily backups will be retained for 7 days (max 35)
        }
        collation: 'SQL_Latin1_General_CP1_CI_AS' // Implicit value, change if required
        diagnosticSettings: [
          {
            logCategoriesAndGroups: diagnosticSettingsCategories.outputs.logsCategories
            metricCategories: diagnosticSettingsCategories.outputs.metricsCategories
            name: '${logAnalyticsWorkspaceId}-customDiagnosticSettings'
            storageAccountResourceId: null // To be configured if extra logs retention is desired
            workspaceResourceId: logAnalyticsWorkspaceId
          }
        ]
        licenseType: 'LicenseIncluded' // Pay-as-you-go for SQL Server license
        maxSizeBytes: 16106127360 // Storage Data size set to 15 GB
        name: sqlDatabaseName
        sku: {
          capacity: 2 // Instance: 2 vCores
          name: 'GP_Gen5'
          tier: 'GeneralPurpose' // Service tier
          family: 'Gen5' // Hardare type: Standard-series
        }
        zoneRedundant: true
      }
    ]
    location: location
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    minimalTlsVersion: '1.3'
    primaryUserAssignedIdentityResourceId: '<primaryUserAssignedIdentityResourceId>'
    privateEndpoints: [
      {
        name: 'pe-${sqlServerName}'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneResourceId
            }
          ]
        }
        privateLinkServiceConnectionName: 'pl-pe-${sqlServerName}'
        service: 'sqlServer'
        subnetResourceId: subNetId
        tags: {
          Environment: environmentType
        }
      }
    ]
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    securityAlertPolicies: [
      {
        emailAccountAdmins: true
        emailAddresses: [
          'marad@netrom.ro'
          // 'netrom.devops@marasoft.nl'
        ]
        name: 'securityAlert'
        state: 'Enabled'
      }
    ]
    tags: {
      Environment: environmentType
    }
    // Weekly scans the SQL Server for vulnerabilites and stores the reports in Storage Account
    vulnerabilityAssessmentsObj: {
      name: 'vulnerabilityAssessmentReport'
      recurringScans: {
        emails: [
          'marad@netrom.ro'
          // 'netrom.devops@marasoft.nl'
        ]
        emailSubscriptionAdmins: false
        isEnabled: true
      }
      storageAccountResourceId: storageAccountId
    }
  }
}

/* -------------------- Private DNS for SQL -------------------- */
module sqlPrivDns 'br/public:avm/res/network/private-dns-zone:0.8.0' = {
  name: 'privatednszonedeployment'
  params: {
    location: location
    name: sqlPrivateDnsZone
  }
}

resource sqlPrivDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivDns.name}/link-${vNet.name}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNet.id
    }
  }
}

resource sqlPeDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  name: '${sqlServerName}/sql-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config-sql'
        properties: {
          privateDnsZoneId: sqlPrivDns.outputs.resourceId
        }
      }
    ]
  }
  dependsOn: [
    sqlServer
    sqlPrivDnsVnetLink
  ]
}
