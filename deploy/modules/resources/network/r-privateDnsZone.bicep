// User input parameters
@allowed(['dev', 'test', 'prod'])
@description('The target deployment environment tag.')
param environmentType string

@allowed([
  'database'
  'servicebus'
  'blob'
  'table'
  'queue'
  'file'
])
@description('The Private DNS Zone`s name will be built based on this service type.')
param serviceType string

// Local variables
var deploymentName = 'pdzdpl-backoffice-${environmentType}-${location}'

var resourceName = contains(['blob', 'table', 'queue', 'file'], serviceType)
  ? 'privatelink.${serviceType}.core.windows.net'
  : 'privatelink.${serviceType}.windows.net'

@description('This resource is global by default. Set for visibility.')
var location = 'global'

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.8.0' = {
  name: deploymentName
  params: {
    name: resourceName
    location: location
    lock: {
      kind: 'CanNotDelete' // This lock needs to be deleted before deleting the actual Private DNS Zone resource
      name: 'DNSZoneProtection'
    }
    tags: {
      Environment: environmentType
    }
  }
}
