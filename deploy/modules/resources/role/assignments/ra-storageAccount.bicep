import { roleDefinitions } from '../definitions/roleDefinitions.bicep'

param appServicePrincipalId string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

// Storage Blob Data Contributor
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, appServicePrincipalId, 'storage-role')
  properties: {
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      roleDefinitions.Storage.StorageBlobDataContributor
    )
  }
}
