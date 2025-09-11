module privateLinkPrivateDnsZones 'br/public:avm/ptn/network/private-link-private-dns-zones:0.6.0' = {
  name: 'privateLinkPrivateDnsZonesDeployment'
  params: {
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: '<virtualNetworkResourceId>'
      }
    ]
  }
}
