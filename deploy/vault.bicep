module kv './modules/resources/key-vault/r-keyVault.bicep' = {
  params: {
    environmentType: 'dev'
    keyword: 'mmlkv'
  }
}

module secret './modules/resources/key-vault/r-keyVaultSecret.bicep' = {
  params: {
    keyVaultName: kv.outputs.name
    secretName: 'mmlsecret'
    secretValue: 'mmlsecretvalue'
  }
}

module key './modules/resources/key-vault/r-keyVaultKey.bicep' = {
  params: {
    keyVaultName: kv.outputs.name
    keyName: 'mmlkey'
  }
}
