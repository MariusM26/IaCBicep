// =============================================================================
// Bicep template for an SQL Server and Database with dedicated Private Endpoint
// =============================================================================

@description('The SQL location based on the parent resource-group.')
var location = resourceGroup().location

@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

var sqlServerDeploymentName = 'SQL-Server-Deployment'

@description('SQL logical server name (globally unique).')
var sqlServerName = 'BOserver-dev-${location}-testPrpse'

@description('SQL database name.')
var sqlDatabaseName = 'BOdatabase-dev-${location}-testPrpse'

@description('Azure AD admin display name')
param serverAdminUsername string = 'marus'

@description('Azure AD admin objectId (user/group/app)')
param aadObjectId string = 'dd6e6f63-e2b1-4532-83a2-b79483d8ef92'
// bicep this //// create rbac based on the bicepconfig import

// Private DNS zone for Azure SQL
var sqlPrivateDnsZone = 'privatelink${environment().suffixes.sqlServerHostname}'

param logAnalyticsWorkspaceName string
param vNetName string

resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vNetName
}

/* -------------------- SQL Server + Database -------------------- */
module sqlServer 'br/public:avm/res/sql/server:0.20.2' = {
  name: sqlServerDeploymentName
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
    customerManagedKey: {
      autoRotationEnabled: true
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
      keyVersion: '<keyVersion>'
    }
    databases: [
      {
        availabilityZone: 1
        backupLongTermRetentionPolicy: {
          monthlyRetention: 'P6M'
        }
        backupShortTermRetentionPolicy: {
          retentionDays: 14
        }
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        diagnosticSettings: [
          {
            eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
            eventHubName: '<eventHubName>'
            name: 'customSetting'
            storageAccountResourceId: '<storageAccountResourceId>'
            workspaceResourceId: '<workspaceResourceId>'
          }
        ]
        elasticPoolResourceId: '<elasticPoolResourceId>'
        licenseType: 'LicenseIncluded'
        maxSizeBytes: 34359738368
        name: 'sqlswafdb-001'
        sku: {
          capacity: 0
          name: 'ElasticPool'
          tier: 'GeneralPurpose'
        }
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
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'sqlServer'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
    ]
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    securityAlertPolicies: [
      {
        emailAccountAdmins: true
        name: 'Default'
        state: 'Enabled'
      }
    ]
    tags: {
      Environment: environmentType
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    virtualNetworkRules: [
      {
        ignoreMissingVnetServiceEndpoint: true
        name: 'newVnetRule1'
        virtualNetworkSubnetResourceId: '<virtualNetworkSubnetResourceId>'
      }
    ]
    vulnerabilityAssessmentsObj: {
      name: 'default'
      recurringScans: {
        emails: [
          'test1@contoso.com'
          'test2@contoso.com'
        ]
        emailSubscriptionAdmins: true
        isEnabled: true
      }
      storageAccountResourceId: '<storageAccountResourceId>'
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  name: '${sqlServer.name}/${sqlDatabaseName}'
  location: location
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    isLedgerOn: false
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    zoneRedundant: false
  }
  dependsOn: [
    sqlServer
  ]
}
/* ----------------------------------------------------------------- */

/* -------------------- Private Endpoint for SQL -------------------- */
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${sqlServer.name}'
  location: location
  properties: {
    subnet: {
      id: vNet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'sqlserver'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

/* -------------------- Private DNS for SQL -------------------- */

resource sqlPrivDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: sqlPrivateDnsZone
  location: 'global'
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
  name: '${sqlPrivateEndpoint.name}/sql-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config-sql'
        properties: {
          privateDnsZoneId: sqlPrivDns.id
        }
      }
    ]
  }
  dependsOn: [
    sqlPrivateEndpoint
    sqlPrivDnsVnetLink
  ]
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsWorkspaceName
}

module diagnosticSettings './r-diagnosticSettings.bicep' = {
  name: 'diag-sql-db'
  scope: resourceGroup()
  params: {
    workspaceId: logAnalyticsWorkspace.id
    sqlDatabaseName: sqlDatabase.name
    ErrorsEnabled: true
    TimeoutsEnabled: true
    BasicMetricsEnabled: true
  }
  dependsOn: [
    logAnalyticsWorkspace
    sqlDatabase
  ]
}
