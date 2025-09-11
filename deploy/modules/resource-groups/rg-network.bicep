@description('The environment in which the deployment is done.)')
param environmentType string
param location string

targetScope = 'subscription'

// Resource Group for Network resources
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-dev-network'
  location: location
  tags: {
    Environment: 'dev'
  }
}

// West Europe Virtual Network
module vNet '../resources/network/r-vNet.bicep' = {
  scope: networkRG
  params: {
    location: location
    environmentType: environmentType
    logAnalyticsWorkspaceId: ''
    networkSecurityGroupId: ''
  }
}

// NSGs
module appServiceSubnetNsg '../resources/network/r-nsg.bicep' = {
  scope: networkRG
  params: {
    location: location
    nsgType: 'appservice'
    environmentType: environmentType
    logAnalyticsWorkspaceId: ''
  }
}

// App Service Subnet
module appServiceSubnet '../resources/network/r-subNet.bicep' = {
  scope: networkRG
  params: {
    resourceName: 'appService'
    vNetName: vNet.outputs.vNetName
    subNetAddressPrefix: '10.0.2.0/24'
    networkSecurityGroupId: appServiceSubnetNsg.outputs.resourceId
    delegations: [
      {
        name: 'delegation-appService'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

// Private Endpoint Subnet
module privateEndpointSubnet '../resources/network/r-subNet.bicep' = {
  scope: networkRG
  params: {
    resourceName: 'privateEndpoint'
    vNetName: vNet.name
    subNetAddressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

// Required
output appServiceSubnetId string = appServiceSubnet.outputs.subnetId
