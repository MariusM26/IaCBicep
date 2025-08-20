param appServicePlanId string = ''
param location string

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'appServicePlanDeployment'
  params: {
    name: 'asp-dev-backoffice'
    kind: 'windows'
    skuName: 'F1'
    skuCapacity: 0
    zoneRedundant: false
  }
}

// module appService 'br/public:avm/res/web/site:0.19.0' = {
//   name: 'appServiceDeployment'
//   params: {
//     kind: 'app'
//     name: 'as-dev-backoffice'
//     serverFarmResourceId: empty(appServicePlanId) ? appServicePlan.outputs.resourceId : appServicePlanId
//     siteConfig: {
//       netFrameworkVersion: 'v8'
//       localMySqlEnabled: false
//       alwaysOn: false
//       windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
//       appSettings: [
//         {
//           name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
//           value: 'false'
//         }
//       ]
//     }
//   }
// }

resource appService 'Microsoft.Web/sites@2024-11-01' = {
  name: 'as-dev-backoffice'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: empty(appServicePlanId) ? appServicePlan.outputs.resourceId : appServicePlanId
    siteConfig: {
      alwaysOn: false
      windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      localMySqlEnabled: false
      netFrameworkVersion: 'v4.6'
    }
  }
}
