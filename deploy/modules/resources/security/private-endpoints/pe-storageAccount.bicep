param location string
param storageAccountName string
param storageAccountId string
@secure()
param subNetId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = {
  name: '${storageAccountName}-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-plsc'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: ['blob']
        }
      }
    ]
    subnet: {
      id: subNetId
    }
  }
}

//////////////////////////// this should be declared with parent resource
