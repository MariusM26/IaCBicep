param location string

module storageAccount 'br/public:avm/res/storage/storage-account:0.26.0' = {
  name: 'storageAccountDeployment'
  params: {
    blobServices: {}
    name: 'sadevmarad'
    location: location
    accessTier: 'Cold'

    kind: 'StorageV2'
    skuName: 'Standard_LRS'
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  name: 'sadevmarad/default'
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01' = {
  #disable-next-line use-parent-property
  name: 'sadevmarad/default/fileshare'
}
