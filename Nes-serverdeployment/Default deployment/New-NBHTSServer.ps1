Import-Module RemoteDesktop

[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU
$TSName = Read-Host "Write the Netbios name of your TS server" 
$Localmachine = hostname


#Deploy Connection broker, Webaccessserver and sessionhost to your TS server 
New-RDSessionDeployment -ConnectionBroker "$TSName.$Netbiosname.local" -WebAccessServer "$TSName.$Netbiosname.local" -SessionHost "$TSName.$Netbiosname.local"

#Wait 5 minutes due to server restart
Start-Sleep 300

#Add Licensingserver on this machine, Should be the DC in most cases
Add-RDServer -Server "$Localmachine.$Netbiosname.local" -Role RDS-LICENSING -ConnectionBroker "$TSName.$Netbiosname.local"

Set-RDLicenseConfiguration -LicenseServer "$Localmachine.$Netbiosname.local" -Mode PerUser -ConnectionBroker "$TSName.$Netbiosname.local"

#Create the Collection
New-RDSessionCollection -CollectionName TSFARM1 -SessionHost "$TSName.$Netbiosname.local" -CollectionDescription "Remote Desktop Collection" -ConnectionBroker "$TSName.$Netbiosname.local"