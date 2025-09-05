import { appServiceRules } from '../resources/security/service-rules/appServiceRules.bicep'
import { privateEndpointRules } from '../resources/security/service-rules/privateEndpointRules.bicep'
import { storageRules } from '../resources/security/service-rules/storageRules.bicep'
import { serviceBusRules } from '../resources/security/service-rules/serviceBusRules.bicep'
import { containerRegistryRules } from '../resources/security/service-rules/containerRegistryRules.bicep'

@description('The location where the NSG will be created')
param location string

@description('The name of the NSG resource')
param resourceName string

@description('Type of NSG rules to apply')
@allowed([
  'appService'
  'privateEndpoint'
  'storage'
  'serviceBus'
  'containerRegistry'
])
param nsgType string

var allRules = {
  appService: appServiceRules
  privateEndpoint: privateEndpointRules
  storage: storageRules
  serviceBus: serviceBusRules
  containerRegistry: containerRegistryRules
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: 'nsg-${resourceName}'
  location: location
  properties: {
    securityRules: allRules[nsgType]
  }
}

output nsgId string = nsg.id
