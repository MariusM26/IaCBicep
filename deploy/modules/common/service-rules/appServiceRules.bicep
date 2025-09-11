@export()
@description('Microsoft Azure Secuirty Rules for NSGs')
var appServiceRules = [
  // Inbound Rules
  {
    name: 'Allow-AppService-Management-Inbound'
    properties: {
      description: 'Allows AppService Management communication on ports 454-455. Required for platform operations and management.'
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '454-455'
      sourceAddressPrefix: 'AppServiceManagement'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'Allow-HTTPS-Inbound'
    properties: {
      description: 'Allows incoming HTTPS traffic (port 443) to app service. Required for external access to web applications and APIs.'
      priority: 110
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'Allow-LoadBalancer-Inbound'
    properties: {
      description: 'Allows Azure Load Balancer health probes and traffic. Required for platform high availability and load balancing.'
      priority: 120
      direction: 'Inbound'
      access: 'Allow'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: '*'
    }
  }
  // Outbound Rules
  {
    name: 'Allow-SQL-Outbound'
    properties: {
      description: 'Allows outbound connections to Azure SQL Database on port 1433. Required for SQL database communication.'
      priority: 100
      direction: 'Outbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '1433'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Sql'
    }
  }
  {
    name: 'Allow-Storage-Outbound'
    properties: {
      description: 'Allows HTTPS connections to Azure Storage services. Required for accessing blobs, files, queues, and tables.'
      priority: 110
      direction: 'Outbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Storage'
    }
  }
  {
    name: 'Allow-AzureMonitor-Outbound'
    properties: {
      description: 'Allows HTTPS connections to Azure Monitor. Required for application logging, monitoring, and diagnostics.'
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
