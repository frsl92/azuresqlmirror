@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Name for the Azure SQL Server (lowercase, unique)')
param sqlServerName string

@description('Admin login for the Azure SQL Server')
param administratorLogin string

@secure()
@description('Admin password for the Azure SQL Server')
param administratorLoginPassword string

@description('Name of the Azure SQL Database to create')
param databaseName string = 'fabricMirrorDemoDb'

@description('Allow all internet IPs to access the server (0.0.0.0 to 255.255.255.255)')
param allowAllInternetIPs bool = true

@description('Client IPv4 start for firewall rule (ignored if allowAllInternetIPs true)')
param startIpAddress string = '0.0.0.0'

@description('Client IPv4 end for firewall rule (ignored if allowAllInternetIPs true)')
param endIpAddress string = '255.255.255.255'

@description('SKU name for the database - Must be Standard S3+ (100+ DTUs) or higher for Fabric mirroring')
param skuName string = 'S3'

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
    version: '12.0'
    primaryUserAssignedIdentityId: null  // System-assigned identity as primary
  }
}

resource db 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    // Using defaults; adjust if needed
  }
}

// Allow all internet IPs (0.0.0.0 to 255.255.255.255) or a custom client IP range
resource firewall 'Microsoft.Sql/servers/firewallRules@2021-11-01' = if (allowAllInternetIPs) {
  parent: sqlServer
  name: 'AllowAllInternetIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource firewallClient 'Microsoft.Sql/servers/firewallRules@2021-11-01' = if (!allowAllInternetIPs) {
  parent: sqlServer
  name: 'ClientIpRange'
  properties: {
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}

output sqlServerName string = sqlServer.name
output sqlFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = databaseName
output administratorLogin string = administratorLogin
output sqlServerPrincipalId string = sqlServer.identity.principalId
output sqlServerTenantId string = sqlServer.identity.tenantId
output connectionStringTemplate string = 'DRIVER={ODBC Driver 18 for SQL Server};SERVER=${sqlServer.properties.fullyQualifiedDomainName};DATABASE=${databaseName};UID=${administratorLogin};PWD=<PASSWORD>;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'
