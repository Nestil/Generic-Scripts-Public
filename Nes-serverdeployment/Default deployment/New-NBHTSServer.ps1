#Deploy Connection broker, Webaccessserver and sessionhost to your TS server 
New-RDSessionDeployment -ConnectionBroker "$TSName.$Netbiosname.local" -WebAccessServer "$TSName.$Netbiosname.local" -SessionHost "$TSName.$Netbiosname.local"

#Wait 5 minutes due to server restart
Start-Sleep 300

#Add Licensingserver on this machine, Should be the DC in most cases
Add-RDServer -Server "$Localmachine.$Netbiosname.local" -Role RDS-LICENSING -ConnectionBroker "$TSName.$Netbiosname.local"

Set-RDLicenseConfiguration -LicenseServer "$Localmachine.$Netbiosname.local" -Mode PerUser -ConnectionBroker "$TSName.$Netbiosname.local"

#Create the Collection
New-RDSessionCollection -CollectionName TSFarm1 -SessionHost "$TSName.$Netbiosname.local" -CollectionDescription "Remote Desktop Collection" -ConnectionBroker "$TSName.$Netbiosname.local"

#Install RDGW components
Add-RDServer -Server "$TSName.$Netbiosname.local" -Role RDS-GATEWAY -GatewayExternalFqdn $GWName -ConnectionBroker "$TSName.$Netbiosname.local"