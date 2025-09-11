// Network Security Group rules for Azure Service Bus
// These rules control access to Service Bus namespaces and their entities (queues, topics)

@export()
var serviceBusRules = [
  {
    // Allow inbound HTTPS traffic from VNet
    name: 'Allow-ServiceBus-Inbound'
    properties: {
      description: 'Allows inbound HTTPS (port 443) traffic from the Virtual Network to Azure Service Bus. This rule enables secure messaging and event-driven communication between applications within the VNet.'
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp' // HTTPS uses TCP
      sourcePortRange: '*'
      destinationPortRange: '443' // HTTPS port
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
    }
  }
  {
    // Allow outbound AMQP traffic
    name: 'Allow-AMQP-Outbound'
    properties: {
      description: 'Allows outbound AMQP (Advanced Message Queuing Protocol) traffic on port 5671 for secure messaging.'
      priority: 110
      direction: 'Outbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '5671'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'ServiceBus'
    }
  }
  {
    // Allow Azure Monitor logging
    name: 'Allow-AzureMonitor-Outbound'
    properties: {
      description: 'Allows outbound traffic to Azure Monitor for Service Bus monitoring and diagnostics.'
      priority: 120
      direction: 'Outbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'AzureMonitor'
    }
  }
]
