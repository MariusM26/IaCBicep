import { roleDefinitions } from '../../../../common/roleDefinitions.bicep'

param appServicePrincipalId string
param serviceBusNamespaceName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusNamespaceName
}

// Service Bus Data Receiver
resource serviceBusRoleAssignmentReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: serviceBusNamespace
  name: guid(serviceBusNamespace.id, appServicePrincipalId, 'servicebus-receiver-role')
  properties: {
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      roleDefinitions.Integration.ServiceBusDataReceiver
    )
  }
}

// Service Bus Data Sender
resource serviceBusRoleAssignmentSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: serviceBusNamespace
  name: guid(serviceBusNamespace.id, appServicePrincipalId, 'servicebus-sender-role')
  properties: {
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      roleDefinitions.Integration.ServiceBusDataSender
    )
  }
}
