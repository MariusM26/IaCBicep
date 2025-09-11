// Network Security Group rules for Azure Container Registry
// These rules control access to container registries and their artifacts

@export()
var containerRegistryRules = [
  {
    // Allow inbound HTTPS traffic from VNet
    name: 'Allow-ACR-Inbound'
    properties: {
      description: 'Allows inbound HTTPS (port 443) traffic from the Virtual Network to Azure Container Registry. This rule enables secure access to container images and artifacts stored in the registry from within the VNet.'
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
    // Allow outbound Docker registry traffic
    name: 'Allow-Docker-Outbound'
    properties: {
      description: 'Allows outbound traffic to Docker registry on port 443 for pulling and pushing container images.'
      priority: 110
      direction: 'Outbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'AzureContainerRegistry'
    }
  }
  {
    // Allow Azure Monitor logging
    name: 'Allow-AzureMonitor-Outbound'
    properties: {
      description: 'Allows outbound traffic to Azure Monitor for container registry analytics and logging.'
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
