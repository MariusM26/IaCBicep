// Network Security Group rules for Azure Storage Account
// These rules control access to Storage Account services including Blob, File, Queue, and Table

@export()
var storageRules = [
  {
    // Allow inbound HTTPS traffic from VNet
    name: 'Allow-Storage-Inbound'
    properties: {
      description: 'Allows inbound HTTPS (port 443) traffic from the Virtual Network to Azure Storage. This rule enables secure access to storage resources like blobs, files, queues, and tables from within the VNet.'
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
    // Allow Storage service tag outbound access
    name: 'Allow-Storage-Outbound'
    properties: {
      description: 'Allows outbound connections to Azure Storage services over HTTPS (port 443). Essential for accessing blob storage, file shares, queues, and tables.'
      priority: 100
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
    // Allow Azure Monitor logging
    name: 'Allow-AzureMonitor-Outbound'
    properties: {
      description: 'Allows outbound traffic to Azure Monitor for storage analytics and logging.'
      priority: 110
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
