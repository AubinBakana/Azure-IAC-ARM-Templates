// DEPLOYS A STORAGE ACCOUNT, ROLE DEFINITION & ASSIGNMENT, AND RELATED DEPLOYMENT SCRIPT RESOURCES.
// APP SETTINGS FILE STAGING AUTOMATION WITH DEPLOYMENT SCRIPT: USING A POWERSHELL SCRIPT WITH DEPLOYMENT SCRIPT RESOURCE
// DEPLOYMENT SCRIPT TRANSFORM A LIST OF FILE NAMES, MAKES AN API REQUEST AND DOWNLOADS CORRESPONDING APPLICATIONS SETTINGS FILE FROM THE WEB; THEN STAGES CONTENT IN BLOB CONTAINER FOR RELATED NEW APPLICATION TO READ

// PARAMETERS & VARIABLES DECLARATIONS
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

@description('List of files to copy to application storage account.')
param filesToCopy array

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

// Script accepts a list of app settings file name, sends an API request to get app settings, then stage content to related app container for each file. Also return output to adminstrator
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
    arguments: '-File \'${string(filesToCopy)}\''
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: storageAccountName
      }
      {
        name: 'StorageContainerName'
        value: storageBlobContainerName
      }
    ]
    scriptContent: '''
    param([string]$File)
    $fileList = $File -replace '(\[|\])' -split ',' | ForEach-Object { $_.trim() }
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $env:ResourceGroupName -Name $env:StorageAccountName -Verbose
    $count = 0
    $DeploymentScriptOutputs = @{}
    foreach ($fileName in $fileList) {
        Write-Host "Copying $fileName to $env:StorageContainerName in $env:StorageAccountName."
        Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/mslearn-arm-deploymentscripts-sample/$fileName" -OutFile $fileName
        $blob = Set-AzStorageBlobContent -File $fileName -Container $env:StorageContainerName -Blob $fileName -Context $storageAccount.Context
        $DeploymentScriptOutputs[$fileName] = @{}
        $DeploymentScriptOutputs[$fileName]['Uri'] = $blob.ICloudBlob.Uri
        $DeploymentScriptOutputs[$fileName]['StorageUri'] = $blob.ICloudBlob.StorageUri
        $count++
    }
    Write-Host "Finished copying $count files."
    '''
    retentionInterval: 'P1D'
  }
}

// OUTPUT
output fileUri object = deploymentScript.properties.outputs
output storageAccountName string = storageAccountName
