param location string = resourceGroup().location
param automationAccountName string = 'provisionassist-auto'
param tenantId string
param appClientId string
@secure()
param appSecret string
param logoUrl string
param keyVaultName string
param appServicePrincipalId string
param saUsername string
@secure()
param saPassword string

// Key vault & secrets
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: appServicePrincipalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultAppIdSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name:  'appid'
  properties: {
    value: appClientId
  }
}

resource keyVaultAppSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name:  'appSecret'
  properties: {
    value: appSecret
  }
}

resource keyVaultsaUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name:  'sausername'
  properties: {
    value: saUsername
  }
}

resource keyVaultsaPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name:  'sapassword'
  properties: {
    value: saPassword
  }
}

// Automation account
resource automationAccount 'Microsoft.Automation/automationAccounts@2019-06-01' = {
  name: automationAccountName
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

// Modules
resource Az_Accounts 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  name: 'Az.Accounts'
  location: location
  parent: automationAccount
  properties: {
    contentLink: {
      uri: 'https://devopsgallerystorage.blob.core.windows.net/packages/az.accounts.1.6.2.nupkg'
      version: '1.6.2'
    }
  }
}

resource PnP_PowerShell 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  name: 'PnP.PowerShell'
  location: location
  parent: automationAccount
  properties: {
    contentLink: {
      uri: 'https://devopsgallerystorage.blob.core.windows.net/packages/pnp.powershell.1.10.0.nupkg'
      version: '1.10.0'
    }
  }
}

// Runbooks
resource getSiteTemplatesRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: 'GetSiteTemplates'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/alexc-MSFT/viva-connections-cards/main/GetSiteTemplates.ps1'
      version: '1.0.0.0'
    }
  }
}

resource configureSpaceRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: 'ConfigureSpace'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/alexc-MSFT/viva-connections-cards/main/ConfigureSpace.ps1'
      version: '1.0.0.0'
    }
  }
}

// Variables
resource tenantIdVariable 'Microsoft.Automation/automationAccounts/variables@2019-06-01' = {
  parent: automationAccount
  name: 'tenantId'
  properties: {
    value: '"${tenantId}"'
    isEncrypted: false
  }
}

resource appClientIdVariable 'Microsoft.Automation/automationAccounts/variables@2019-06-01' = {
  parent: automationAccount
  name: 'appClientId'
  properties: {
    value: '"${appClientId}"'
    isEncrypted: false
  }
}

resource appSecretVariable 'Microsoft.Automation/automationAccounts/variables@2019-06-01' = {
  parent: automationAccount
  name: 'appSecret'
  properties: {
    value: '"${appSecret}"'
    isEncrypted: true
  }
}

resource logoUrlVariable 'Microsoft.Automation/automationAccounts/variables@2019-06-01' = {
  parent: automationAccount
  name: 'logoUrl'
  properties: {
    value: '"${logoUrl}"'
    isEncrypted: false
  }
}



