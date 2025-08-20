param location string

// module storageAccount 'br/public:avm/res/storage/storage-account:0.26.0' = {
//   name: 'storageAccountDeployment'
//   params: {
//     blobServices: {}
//     name: 'sadevmarad'
//     location: location
//     accessTier: 'Cold'

//     kind: 'StorageV2'
//     skuName: 'Standard_LRS'
//     customDomainUseSubDomainName: null
//   }
// }

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'sadevmarad'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cold'
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
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01' = {
  #disable-next-line use-parent-property
  name: 'sadevmarad/default/fileshare'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
  }
}
