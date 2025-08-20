param appServicePlanId string = ''

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'appServicePlanDeployment'
  params: {
    name: 'asp-dev-backoffice'
    kind: 'windows'
    skuName: 'F1'
    skuCapacity: 1
    zoneRedundant: false
  }
}

module appService 'br/public:avm/res/web/site:0.19.0' = {
  name: 'appServiceDeployment'
  params: {
    kind: 'app,container,windows'
    name: 'as-dev-backoffice'
    serverFarmResourceId: empty(appServicePlanId) ? appServicePlan.outputs.resourceId : appServicePlanId
    siteConfig: {
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
  }
}
