param location string = 'WestEurope'

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'mmlstorageaccount'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cold'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
    }
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  #disable-next-line use-parent-property
  name: 'mmlstorageaccount/default'
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
  name: 'mmlstorageaccount/default/mmlfileshare'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
  }
  dependsOn: [
    fileServices
  ]
}

// West Europe Virtual Network
module vNet './modules/resources/r-vNet.bicep' = {
  scope: resourceGroup()
  params: {
    location: location
    environmentType: 'dev'
    addressPrefix: '10.0.0.0/16'
  }
}

resource vnetlocal 'Microsoft.ScVmm/virtualNetworks@2025-03-13' existing = {
  name: 'mml-vnet'
}

module NSG './modules/resources/r-nsg.bicep' = {
  scope: resourceGroup()
  params: {
    location: location
    resourceName: 'peNSG'
    nsgType: 'privateEndpoint'
  }
}

// Private Endpoint Subnet
module subnet './modules/resources/r-subNet.bicep' = {
  scope: resourceGroup()
  params: {
    resourceName: 'mmlPrivateEndpoint'
    vNetName: vNet.outputs.vNetName
    subNetAddressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: NSG.outputs.nsgId
  }
}

// -------------------- Private DNS --------------------
resource pdns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  #disable-next-line no-hardcoded-env-urls
  name: 'privatelink.file.core.windows.net'
  location: 'global'
}

resource pdnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${pdns.name}/vnet-weu-files-link'
  location: 'global'
  properties: {
    virtualNetwork: { id: vNet.outputs.vNetId }
    registrationEnabled: false
  }
}

// -------------------- Private Endpoint (subresource: file) --------------------
resource privateEndpointStorageAccount 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: 'pe-${storageAccount.name}-file'
  location: location
  properties: {
    subnet: {
      id: subnet.outputs.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pls-${storageAccount.name}-file'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['file'] // subresource for Azure Files
          requestMessage: 'PE for Azure Files'
        }
      }
    ]
  }
}

// Prefer: Private DNS Zone Group for automatic A record management
resource pzGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-05-01' = {
  #disable-next-line use-parent-property
  name: '${privateEndpointStorageAccount.name}/pdz-${uniqueString(storageAccount.id, vnetlocal.id)}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'cfg-file'
        properties: {
          privateDnsZoneId: pdns.id
        }
      }
    ]
  }
}

// -------------------- Outputs --------------------
output storageAccountId string = storageAccount.id
#disable-next-line no-hardcoded-env-urls
output fileShareUrl string = 'https://${storageAccount.name}.file.core.windows.net/mmlstorageaccount/default/mmlfileshare'
output vnetId string = vNet.outputs.vNetId
output privateEndpointId string = privateEndpointStorageAccount.id
