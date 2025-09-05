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
module vNet '../resources/r-vNet.bicep' = {
  scope: networkRG
  params: {
    location: location
    environmentType: environmentType
    addressPrefix: '10.0.0.0/16'
  }
}

// NSGs
module appServiceSubnetNsg '../resources/r-nsg.bicep' = {
  scope: networkRG
  params: {
    location: location
    resourceName: 'appService'
    nsgType: 'appService'
  }
}

// App Service Subnet
module appServiceSubnet '../resources/r-subNet.bicep' = {
  scope: networkRG
  params: {
    resourceName: 'appService'
    vNetName: vNet.outputs.vNetName
    subNetAddressPrefix: '10.0.2.0/24'
    networkSecurityGroupId: appServiceSubnetNsg.outputs.nsgId
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
module privateEndpointSubnet '../resources/r-subNet.bicep' = {
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
