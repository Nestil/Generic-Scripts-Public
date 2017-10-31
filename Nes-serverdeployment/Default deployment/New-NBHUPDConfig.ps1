Import-Module RemoteDesktop

[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU
$TSName = Read-Host "Write the Netbios name of your TS server" 
$FSName = Read-Host "Write the Netbios name of your File server" 
$Localmachine = hostname

#Create UPD Configration
Set-RDSessionCollectionConfiguration -TSFarm1 "Desktopsessioncollection" –EnableUserProfileDisk -MaxUserProfileDiskSizeGB50 `
-DiskPath "\\$FSNAME.$AD.local\Profiles" -IncludeFilePath @("ntuser.dat") `
-ConnectionBroker $TSName.$AD.local