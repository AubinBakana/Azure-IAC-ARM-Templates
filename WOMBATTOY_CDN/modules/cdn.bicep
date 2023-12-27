// MODULE: CDN Profile and endpoint.

// Declare variables and parameters.
@description('Name of the CDN resource')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('Name of the CDN endpoint')
param endPointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Hostname address of the origin server')
param originHostName string

@description('Indicates whether the CDN endpoint requires HTTPS connections.')
param httpsOnly bool

var originName = 'my-origin'


// DEFINING RESOURCES
resource CdnProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  parent: CdnProfile
  name: endPointName
  location: 'global'
  properties: {
    originHostHeader: originHostName
    isHttpAllowed: !httpsOnly 
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'      
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: originName
        properties: {
          hostName: originHostName
        }
      }      
  ]
  }
}


@description('The host name of the CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
