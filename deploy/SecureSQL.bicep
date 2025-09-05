import { sqlRules } from './modules/resources/security/service-rules/sqlRules.bicep'

@description('Environment type for resource naming (e.g., dev, test, prod)')
param environmentType string = 'dev'

@description('Deployment location')
param location string = 'northeurope'

@description('VNet name')
param vnetName string = 'weu-vnet'

@description('VNet address space')
param vnetCidr string = '10.20.0.0/16'

@description('Subnet for SQL Private Endpoints')
param sqlPeSubnetName string = 'snet-sql-pe'

@description('SQL PE subnet CIDR')
param sqlPeSubnetCidr string = '10.20.10.0/24'

@description('NSG name for SQL PE subnet')
param sqlPeNsgName string = 'nsg-sql-pe'

/* -------------------- Networking -------------------- */
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }
    subnets: [
      {
        name: sqlPeSubnetName
        properties: {
          addressPrefix: sqlPeSubnetCidr
          privateEndpointNetworkPolicies: 'Disabled' // required for PE subnets
          networkSecurityGroup: {
            id: sqlPeNsg.id
          }
        }
      }
    ]
  }
}

resource sqlPeNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: sqlPeNsgName
  location: location
  properties: {
    securityRules: sqlRules
  }
}

/* -------------------- Diagnostic settings to Log Analytics -------------------- */
module logAnalytics './modules/resources/r-logAnalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  scope: resourceGroup()
  params: {
    environmentType: environmentType
    location: location
  }
}

/* -------------------- Key Vault -------------------- */
@minLength(3)
@maxLength(24)
@description('Key Vault name')
param keyVaultName string = 'kv-dev-${location}-test'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: 'Enabled' // poate fi schimbat pe Private Endpoint în etapa următoare
  }
}

/* Notă: când va fi nevoie, adăugați Private Endpoint și pentru Key Vault și zona privată privatelink.vaultcore.azure.net, similar cu SQL. */
