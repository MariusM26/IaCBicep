param location string

var servicebusName string = 'sb-dev-marad'
var servicebusTopicName string = '${servicebusName}/topic1'
var servicebusSubscriptionName string = '${servicebusTopicName}/sub1'

module servicebus 'br/public:avm/res/service-bus/namespace:0.15.0' = {
  name: 'serviceBusNamespaceDeployment'
  params: {
    name: servicebusName
    location: location
    skuObject: {
      name: 'Standard'
    }
    zoneRedundant: false
  }
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = {
  name: servicebusTopicName
  dependsOn: [
    servicebus
  ]
  properties: {
    autoDeleteOnIdle: 'P1D'
    defaultMessageTimeToLive: 'P1D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    maxMessageSizeInKilobytes: 256
    maxSizeInMegabytes: 1024
    supportOrdering: false
  }
}

resource serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = {
  name: servicebusSubscriptionName
  dependsOn: [
    serviceBusTopic
  ]
  properties: {
    maxDeliveryCount: 1
    lockDuration: 'PT5M'
    autoDeleteOnIdle: 'P1D'
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P1D'
    enableBatchedOperations: true
    isClientAffine: false
  }
}
