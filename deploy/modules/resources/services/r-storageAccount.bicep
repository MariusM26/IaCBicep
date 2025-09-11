param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'sadevmarad'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cold'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////// To be AVMED

module t 'br/public:avm/res/storage/storage-account:0.26.2' = {
  params: {
    name: ''
    privateEndpoints: [
      {
        name: 'sadevmarad-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
        service: ''
        subnetResourceId: ''
      }
    ]
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  #disable-next-line use-parent-property
  name: 'sadevmarad/default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
  dependsOn: [
    storageAccount
  ]
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01' = {
  #disable-next-line use-parent-property
  name: 'sadevmarad/default/fileshare'
  properties: {
    enabledProtocols: 'SMB'
    accessTier: 'TransactionOptimized'
    shareQuota: 20
  }
  dependsOn: [
    fileServices
  ]
}
