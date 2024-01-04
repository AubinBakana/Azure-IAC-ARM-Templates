// DEPLOYS A STORAGE ACCOUNT, ROLE DEFINITION & ASSIGNMENT, AND RELATED DEPLOYMENT SCRIPT RESOURCES.
// APP SETTINGS FILE STAGING AUTOMATION WITH DEPLOYMENT SCRIPT: USING A POWERSHELL SCRIPT WITH DEPLOYMENT SCRIPT RESOURCE, DEPLOYMENT ALSO DOWNLOADS APPLICATIONS SETTING FILE FROM THE WEB AND SAVES CONTENT TO STAGE IN BLOB CONTAINER FOR AN APPLICATION TO READ

// PARAMETERS & VARIABLES DECLARATIONS
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

var storageBlobContainerName = 'config'
var userAssignedManagedIdentityName = 'configDeployer'
var roleAssignmentName = guid(resourceGroup().id, 'contributor')
var contributorRoleDefinition = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var deploymentScriptName = 'CopyConfigScripts'


// RESOURCES
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedManagedIdentityName
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: {
      dispalyName: storageAccountName
  }
  kind: 'StorageV2'
  sku: {
      name: 'Standard_LRS'
      tier: 'Standard'
  }
   properties: {
      encryption: {
        keySource: 'Microsoft.Storage'
        services: {
          blob: {
            enabled: true
          }
        }
      }
     supportsHttpsTrafficOnly: true
   }

   resource blobService 'blobServices' existing = {
     name: 'default'
   }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  parent: storageAccount::blobService
  name: storageBlobContainerName
  properties: {
    publicAccess: 'Blob'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleDefinition
    principalId: userAssignedManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  dependsOn: [
    roleAssignment
    blobContainer
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: '''
      Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/mslearn-arm-deploymentscripts-sample/appsettings.json' -OutFile 'appsettings.json'
      $storageAccount = Get-AzStorageAccount -ResourceGroupName 'learndeploymentscript_exercise_1' | Where-Object { $_.StorageAccountName -like 'storage*' }
      $blob = Set-AzStorageBlobContent -File 'appsettings.json' -Container 'config' -Blob 'appsettings.json' -Context $storageAccount.Context
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['Uri'] = $blob.ICloudBlob.Uri
      $DeploymentScriptOutputs['StorageUri'] = $blob.ICloudBlob.StorageUri
    '''
    retentionInterval: 'P1D'
  }
}

// OUTPUT
output fileUri string = deploymentScript.properties.outputs.Uri
