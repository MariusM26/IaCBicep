// App Service Plan params
param appServicePlanName string
param appServicePlanKind string
param appServicePlanSku string
param appServicePlanSkuCapacity int = 0
param appServicePlanZoneRedundant bool = false
// Aoo Service params
param appServiceName string
param appServiceLocation string
param appServiceKind string
param subnetId string
param appServicePlanId string = ''
param dockerImage string = ''
// Common variables
var isAppServicePlanAvailable = !empty(appServicePlanId)

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = if (!isAppServicePlanAvailable) {
  name: 'appServicePlanDeployment'
  scope: resourceGroup()
  params: {
    name: appServicePlanName
    kind: appServicePlanKind
    skuName: appServicePlanSku
    skuCapacity: appServicePlanSkuCapacity
    zoneRedundant: appServicePlanZoneRedundant
  }
}

module appService 'br/public:avm/res/web/site:0.19.0' = {
  name: 'appServiceDeployment'
  scope: resourceGroup()
  params: {
    name: appServiceName
    location: appServiceLocation
    kind: appServiceKind
    virtualNetworkSubnetResourceId: subnetId
    serverFarmResourceId: isAppServicePlanAvailable ? appServicePlanId : appServicePlan!.outputs.resourceId
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      // Determines if the app should be continuously running or unload after being idle
      // Set to false for Free/Shared tiers as they don't support always-on
      alwaysOn: false

      // Specifies the Windows container image to use
      // Format: DOCKER|<registry>/<image>:<tag>
      // Using a default parking page container for initial setup
      windowsFxVersion: dockerImage
      // windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'

      // Application settings that configure the app's behavior
      appSettings: [
        {
          // Controls whether the app uses Azure App Service's persistent storage
          // Set to false for containerized apps to ensure stateless behavior
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          // Forces all outbound traffic to go through the VNet
          // Essential for network isolation and security
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          // Specifies Azure's DNS server IP for resolving both public and private endpoints
          // Required for proper name resolution when using VNet integration
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}

output appServicePrincipalId string = appService.outputs.systemAssignedMIPrincipalId!
