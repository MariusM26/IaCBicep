import { customerManagedKeyWithAutoRotateType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'

@description('Optional. The customer managed key definition for server TDE.')
param customerManagedKey customerManagedKeyWithAutoRotateType?

@description('Optional. The managed identity definition for this resource.')
param location string = 'NorthEurope'

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource cMKKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId)) {
  name: last(split(customerManagedKey.?keyVaultResourceId!, '/'))
  scope: resourceGroup(
    split(customerManagedKey.?keyVaultResourceId!, '/')[2],
    split(customerManagedKey.?keyVaultResourceId!, '/')[4]
  )

  resource cMKKey 'keys@2024-11-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId) && !empty(customerManagedKey.?keyName)) {
    name: customerManagedKey.?keyName!
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource server 'Microsoft.Sql/servers@2023-08-01' = {
  name: 'sql-server-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'marus'
    administratorLoginPassword: 'Pass123$'
    isIPv6Enabled: 'Disabled'
    keyId: customerManagedKey != null
      ? !empty(customerManagedKey.?keyVersion)
          ? '${cMKKeyVault::cMKKey.?properties.keyUri}/${customerManagedKey!.?keyVersion}'
          : cMKKeyVault::cMKKey.?properties.keyUriWithVersion
      : null
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource database 'Microsoft.Sql/servers/databases@2023-08-01' = {
  name: 'myFirstSqlDatabase'
  parent: server
  location: location
  sku: {
    name: 'GP_Gen5_2'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    autoPauseDelay: -1 // -1 = no auto-pause - works only in Serverless tier
    availabilityZone: 'NoPreference'
    encryptionProtector: customerManagedKey != null
      ? !empty(customerManagedKey.?keyVersion)
          ? '${cMKKeyVault::cMKKey.?properties.keyUri}/${customerManagedKey!.?keyVersion}'
          : cMKKeyVault::cMKKey.?properties.keyUriWithVersion
      : null
    encryptionProtectorAutoRotation: customerManagedKey.?autoRotationEnabled
    freeLimitExhaustionBehavior: 'AutoPause'
    highAvailabilityReplicaCount: 0
    isLedgerOn: false
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    zoneRedundant: false
  }
}
