param location string = 'WestEurope'
param env string = 'dev'

targetScope = 'subscription'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Resource Group & ACR
module resourceGroupCommon 'modules/resource-groups/rg-common.bicep' = {
  scope: subscription()
  params: {
    environmentType: env
  }
}

// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Network
// module vNet './modules/resources/r-vNet.bicep' = {
//   scope: resourceGroup('rg-common')
//   params: {
//     location: location
//     environmentType: 'dev'
//     addressPrefix: '10.0.0.0/16'
//   }
// }

// module appServiceSubnetNsg './modules/resources/r-nsg.bicep' = {
//   scope: resourceGroup('rg-common')
//   params: {
//     location: location
//     resourceName: 'appService'
//     nsgType: 'appService'
//   }
// }

// // App Service Subnet
// module appServiceSubnet './modules/resources/r-subNet.bicep' = {
//   scope: resourceGroup('rg-common')
//   params: {
//     resourceName: 'appService'
//     vNetName: vNet.outputs.vNetName
//     subNetAddressPrefix: '10.0.2.0/24'
//     networkSecurityGroupId: appServiceSubnetNsg.outputs.nsgId
//     delegations: [
//       {
//         name: 'delegation-appService'
//         properties: {
//           serviceName: 'Microsoft.Web/serverFarms'
//         }
//       }
//     ]
//   }
// }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Container

module appService './modules/resources/r-appService.bicep' = {
  scope: resourceGroup('rg-dev-common')
  dependsOn: [
    resourceGroupCommon
  ]
  params: {
    // App Service Plan params
    appServicePlanName: 'asp-dev-backoffice'
    appServicePlanKind: 'windows'
    appServicePlanSku: 'S3'
    appServicePlanSkuCapacity: 1
    appServiceName: 'as-dev-backoffice'
    appServiceLocation: location
    appServiceKind: 'app'
    subnetId: ''
  }
}

module acrPullRoleAssignment 'modules/roles/assignments/ra-containerRegistry.bicep' = {
  scope: resourceGroup('rg-dev-common')
  params: {
    appServicePrincipalId: appService.outputs.appServicePrincipalId
    containerRegistryName: 'crmaraddev'
  }
}
resource app 'Microsoft.Web/sites@2024-11-01' existing = {
  scope: resourceGroup('rg-dev-common')
  name: 'as-dev-backoffice'
}

module appConfig 'br/public:avm/res/web/site/config:0.1.0' = {
  scope: resourceGroup('rg-dev-common')
  dependsOn: [
    acrPullRoleAssignment
  ]
  params: {
    name: 'authsettings'
    appName: app.name
    properties: {
      windowsFxVersion: 'DOCKER|crmaraddev.azurecr.io/innosetup:latest'
    }
  }
}

module storageAccount './modules/resources/r-storageAccount.bicep' = {
  scope: resourceGroup('rg-dev-common')
  params: {
    location: location
  }
  dependsOn: [
    resourceGroupCommon
  ]
}
