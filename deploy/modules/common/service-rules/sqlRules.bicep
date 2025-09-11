// Network Security Group rules for Azure SQL Database
// These rules control access to SQL vNet endpoints

@export()
var sqlRules = [
  {
    name: 'AllowVNet'
    properties: {
      priority: 200
      access: 'Allow'
      direction: 'Inbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
    }
  }
  {
    name: 'DenyInternetInbound'
    properties: {
      priority: 400
      access: 'Deny'
      direction: 'Inbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: '*'
    }
  }
  // Outbound allow to VNet (typical default)
  {
    name: 'AllowVNetOutbound'
    properties: {
      priority: 600
      access: 'Allow'
      direction: 'Outbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
    }
  }
]
