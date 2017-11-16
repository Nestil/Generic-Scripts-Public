<#
  .Synopsis
   This script installs the RDS Environment. 
   The script will be started from OneScripttoRuleThemAll.ps1
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
      
  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>

#Deploy Connection broker, Webaccessserver and sessionhost to your TS server 
New-RDSessionDeployment -ConnectionBroker "$TSName.$Domainname" -WebAccessServer "$TSName.$Domainname" -SessionHost "$TSName.$Domainname"

#Wait 5 minutes due to server restart
Start-Sleep 300

#Add Licensingserver on this machine, Should be the DC in most cases
Add-RDServer -Server "$Localmachine.$Domainname" -Role RDS-LICENSING -ConnectionBroker "$TSName.$Domainname"

Set-RDLicenseConfiguration -LicenseServer "$Localmachine.$Domainname" -Mode PerUser -ConnectionBroker "$TSName.$Domainname" -Force

#Create the Collection
New-RDSessionCollection -CollectionName TSFarm1 -SessionHost "$TSName.$Domainname" -CollectionDescription "Remote Desktop Collection" -ConnectionBroker "$TSName.$Domainname"
sleep 60

#Install RDGW components
Add-RDServer -Server "$TSName.$Domainname" -Role RDS-GATEWAY -GatewayExternalFqdn $GWName -ConnectionBroker "$TSName.$Domainname"