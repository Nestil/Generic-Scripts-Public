Import-Module RemoteDesktop
Import-Module ActiveDirectory

[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU
$DCName = Read-Host "Write the Netbios name of your DC Server"
$TSName = Read-Host "Write the Netbios name of your TS server" 
$FSName = Read-Host "Write the Netbios name of your Fileserver"
$GWName = Read-Host "Enter the name of the RDGW FQDN"
$Nestilpwd = Read-Host "Enter password for nestiladmins"
$Localmachine = hostname

#Run New-NBHTSServer
& 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHTSServer.ps1'
sleep 60

#Run New-NBHADStructure
& 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHADStructure.ps1'

sleep 60
#Install Seach Service on RDS and Fileserver
Add-WindowsFeature -Name "Search-Service" -ComputerName $TSName  
sleep 60
Add-WindowsFeature -Name "Search-Service" -ComputerName $FSName  
sleep 60

#Copy Repofolder to Fileserver
Invoke-Command -ComputerName $FSName -ScriptBlock {mkdir c:\Repo} 
Invoke-Command -ComputerName $FSName -ScriptBlock {New-SmbShare -Name "Repo$" -Path "c:\Repo" -FullAccess "Everyone"} 
Robocopy c:\Repo \\KjernellFS\Repo$ /MIR
Invoke-Command -ComputerName $FSName -ScriptBlock {Remove-SmbShare -Name Repo$ -Force} 
 `
#Run New-NBHSharedFolders from FS server and then exit the session
Invoke-Command -ComputerName $FSName -FilePath 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHSharedFolders.ps1'
sleep 60

#Set UPD Configuration
Set-RDSessionCollectionConfiguration -CollectionName TSFarm1 -ConnectionBroker "$TSName.$Netbiosname.local" -EnableUserProfileDisk -MaxUserProfileDiskSizeGB 50 -DiskPath \\$FSName\UPD$

#Install Windows Activation (Needs manual configuration afterwards)
Add-WindowsFeature -Name VolumeActivation -IncludeAllSubFeature -IncludeManagementTools

#Copy sysvol
Robocopy C:\Repo\Generic-Scripts-Public\AD\sysvol \\$Netbiosname.local\Sysvol\$Netbiosname.local\scripts\ /MIR

#Enable Search service on FS and RDS
Set-Service -Name Wsearch -Status Running -PassThru -ComputerName $TSName -StartupType Automatic
Set-Service -Name Wsearch -Status Running -PassThru -ComputerName $FSName -StartupType Automatic