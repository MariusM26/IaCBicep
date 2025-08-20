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
}

resource serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = {
  name: servicebusSubscriptionName
  dependsOn: [
    serviceBusTopic
  ]
  properties: {
    maxDeliveryCount: 1
    lockDuration: 'PT5M'
  }
}
