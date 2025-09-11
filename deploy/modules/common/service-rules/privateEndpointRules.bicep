// Network Security Group rules for Private Endpoints
// These rules control access to private endpoints in Azure

@export()
var privateEndpointRules = [
  {
    // Allow inbound traffic from Virtual Network to Private Endpoint
    name: 'Allow-PE-Inbound'
    properties: {
      description: 'Allows inbound traffic from within the vNet to PE. This rule enables secure communication between resources in the VNet and the PE service.'
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      protocol: '*' // Allows all protocols (TCP, UDP, ICMP)
      sourcePortRange: '*' // From any source port
      destinationPortRange: '*' // To any destination port
      sourceAddressPrefix: 'VirtualNetwork' // Only from resources within the VNet
      destinationAddressPrefix: '*'
    }
  }
  {
    // Explicitly deny all internet inbound traffic for security
    name: 'Deny-Internet-Inbound'
    properties: {
      description: 'Denies inbound internet traffic as security measure ensuring that the PE is only accessible from within the vNet, not from public internet.'
      priority: 4096 // Lowest priority - evaluated last
      access: 'Deny'
      direction: 'Inbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: '*'
    }
  }
  {
    // Allow Azure Load Balancer inbound traffic
    name: 'Allow-AzureLB-Inbound'
    properties: {
      description: 'Allows inbound traffic from Azure Load Balancer for health probes and service operations.'
      priority: 110
      direction: 'Inbound'
      access: 'Allow'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: '*'
    }
  }
]
