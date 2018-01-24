<#
  .Synopsis
    This Script is the masterscript that takes care of the deploymentscripts. Run this one AFTER New-NBHADForest.ps1.

    The Script will Run:
    1. New-NBHTSServer 
    2. New-NBHADStructure
    3. Install the Search Service on RDS and Fileserver
    4. Copy Repo folder from local server to Fileserver
    5. Runs New-NBHSharedFolder from the local disk on Fileserver
    6. Configure User Profile Disks
    7. Install Volume Activation Role (Need manual configuration afterwards)
    8. Copy Sysvol scripts to correct folder
    9. Activate Search services on RDS and File servers. 
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
    
    Things to add in the future: Automate Volume Activation Role and Automate the manual steps of RDS.
      
  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>

Import-Module RemoteDesktop
Import-Module ActiveDirectory

[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
$Netbiosname = $AD.AD.Netbios
$Domainname = $AD.AD.Domainname
$FirstOU = $AD.AD.FirstOU
$DCName = Read-Host "Write the Netbios name of your DC Server"
$TSName = Read-Host "Write the Netbios name of your TS server" 
$FSName = Read-Host "Write the Netbios name of your Fileserver"
$GWName = Read-Host "Enter the name of the RDGW FQDN"
$Nestilpwd = Read-Host "Enter password for nestiladmins"
$Localmachine = hostname
Write-Host -BackgroundColor White -ForegroundColor Black "--------------------------------------------------------------------"
Write-Host  -BackgroundColor White -ForegroundColor Black "Now is a good time to grab some caffeine. This will take a while... "
Write-Host  -BackgroundColor White -ForegroundColor Black "--------------------------------------------------------------------"

#Run New-NBHTSServer
& 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHTSServer.ps1'
sleep 300
#Copy sysvol
Robocopy C:\Repo\Generic-Scripts-Public\AD\sysvol \\$Domainname\Sysvol\$Domainname\scripts\ /MIR
sleep 120

#Run New-NBHADStructure
& 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHADStructure.ps1'

sleep 60
#Install Search Service on RDS and Fileserver
Add-WindowsFeature -Name "Search-Service" -ComputerName $TSName  
Add-WindowsFeature -Name "Search-Service" -ComputerName $FSName  
sleep 60

#Copy Repofolder to Fileserver
Invoke-Command -ComputerName $FSName -ScriptBlock {mkdir c:\Repo} 
Invoke-Command -ComputerName $FSName -ScriptBlock {New-SmbShare -Name "Repo$" -Path "c:\Repo" -FullAccess "Everyone"} 
Robocopy c:\Repo \\$FSName\Repo$ /MIR
Invoke-Command -ComputerName $FSName -ScriptBlock {Remove-SmbShare -Name Repo$ -Force} 
 `
#Run New-NBHSharedFolders from FS server and then exit the session
Invoke-Command -ComputerName $FSName -FilePath 'C:\Repo\Generic-Scripts-Public\Nes-serverdeployment\Default deployment\New-NBHSharedFolders.ps1'
sleep 60

#Set UPD Configuration
Set-RDSessionCollectionConfiguration -CollectionName TSFarm1 -ConnectionBroker "$TSName.$Domainname" -EnableUserProfileDisk -MaxUserProfileDiskSizeGB 100 -DiskPath \\$FSName\UPD$

#Install Windows Activation (Needs manual configuration afterwards)
Add-WindowsFeature -Name VolumeActivation -IncludeAllSubFeature -IncludeManagementTools

#Enable Search service on FS and RDS
Set-Service -Name Wsearch -Status Running -PassThru -ComputerName $TSName -StartupType Automatic
Set-Service -Name Wsearch -Status Running -PassThru -ComputerName $FSName -StartupType Automatic
Set-Service -Name MapsBroker -Status Stopped -PassThru -ComputerName $Localmachine -StartupType Disabled
Set-Service -Name MapsBroker -Status Stopped -PassThru -ComputerName $TSName -StartupType Disabled
Set-Service -Name MapsBroker -Status Stopped -PassThru -ComputerName $FSName -StartupType Disabled

#Move Servers in AD to correct OU
Get-ADComputer -Identity $TSName | Move-ADObject -TargetPath ('OU=RDS,OU=Servers,OU='+$FirstOu+',DC='+$FirstOu+',DC=local')
Get-ADComputer -Identity $FSName | Move-ADObject -TargetPath ('OU=Servers,OU='+$FirstOu+',DC='+$FirstOu+',DC=local')

#Activate Shadow Copies on all server harddrives
#DC Shadowcopies
$diskname = "C:\"
$VolumeWmi = Get-WmiObject Win32_Volume -Namespace root/cimv2 | Where-Object{ $_.Name -eq $diskname }
$DeviceID = $VolumeWmi.DeviceID.ToUpper().Replace("\\?\VOLUME", "").Replace("\","")
$TaskName = "ShadowCopyVolume" + $DeviceID
$TaskFor = "\\?\Volume" + $DeviceID + "\"
$Task = "C:\Windows\system32\vssadmin.exe"
$Argument = "Create Shadow /AutoRetry=15 /For=$TaskFor"
$WorkingDir = "%systemroot%\system32"

$ScheduledAction = New-ScheduledTaskAction –Execute $Task -WorkingDirectory $WorkingDir -Argument $Argument
$ScheduledTrigger = @()
$ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 07:00
$ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 12:00
$ScheduledSettings = New-ScheduledTaskSettingsSet -Compatibility V1 -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3) -Priority 5
$ScheduledTask = New-ScheduledTask -Action $ScheduledAction -Trigger $ScheduledTrigger -Settings $ScheduledSettings
Register-ScheduledTask $TaskName -InputObject $ScheduledTask -User "NT AUTHORITY\SYSTEM"
#FS Shadowcopies
Invoke-Command -ComputerName $FSName -ScriptBlock{

  $diskname = "C:\"
  $VolumeWmi = Get-WmiObject Win32_Volume -Namespace root/cimv2 | Where-Object{ $_.Name -eq $diskname }
  $DeviceID = $VolumeWmi.DeviceID.ToUpper().Replace("\\?\VOLUME", "").Replace("\","")
  $TaskName = "ShadowCopyVolume" + $DeviceID
  $TaskFor = "\\?\Volume" + $DeviceID + "\"
  $Task = "C:\Windows\system32\vssadmin.exe"
  $Argument = "Create Shadow /AutoRetry=15 /For=$TaskFor"
  $WorkingDir = "%systemroot%\system32"
  
  $ScheduledAction = New-ScheduledTaskAction –Execute $Task -WorkingDirectory $WorkingDir -Argument $Argument
  $ScheduledTrigger = @()
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 07:00
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 12:00
  $ScheduledSettings = New-ScheduledTaskSettingsSet -Compatibility V1 -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3) -Priority 5
  $ScheduledTask = New-ScheduledTask -Action $ScheduledAction -Trigger $ScheduledTrigger -Settings $ScheduledSettings
  Register-ScheduledTask $TaskName -InputObject $ScheduledTask -User "NT AUTHORITY\SYSTEM"

  $diskname = "E:\"
  $VolumeWmi = Get-WmiObject Win32_Volume -Namespace root/cimv2 | Where-Object{ $_.Name -eq $diskname }
  $DeviceID = $VolumeWmi.DeviceID.ToUpper().Replace("\\?\VOLUME", "").Replace("\","")
  $TaskName = "ShadowCopyVolume" + $DeviceID
  $TaskFor = "\\?\Volume" + $DeviceID + "\"
  $Task = "C:\Windows\system32\vssadmin.exe"
  $Argument = "Create Shadow /AutoRetry=15 /For=$TaskFor"
  $WorkingDir = "%systemroot%\system32"
  
  $ScheduledAction = New-ScheduledTaskAction –Execute $Task -WorkingDirectory $WorkingDir -Argument $Argument
  $ScheduledTrigger = @()
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 07:00
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 12:00
  $ScheduledSettings = New-ScheduledTaskSettingsSet -Compatibility V1 -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3) -Priority 5
  $ScheduledTask = New-ScheduledTask -Action $ScheduledAction -Trigger $ScheduledTrigger -Settings $ScheduledSettings
  Register-ScheduledTask $TaskName -InputObject $ScheduledTask -User "NT AUTHORITY\SYSTEM"

}
#RDS Shadowcopies
Invoke-Command -ComputerName $TSName -ScriptBlock {
  $diskname = "C:\"
  $VolumeWmi = Get-WmiObject Win32_Volume -Namespace root/cimv2 | Where-Object{ $_.Name -eq $diskname }
  $DeviceID = $VolumeWmi.DeviceID.ToUpper().Replace("\\?\VOLUME", "").Replace("\","")
  $TaskName = "ShadowCopyVolume" + $DeviceID
  $TaskFor = "\\?\Volume" + $DeviceID + "\"
  $Task = "C:\Windows\system32\vssadmin.exe"
  $Argument = "Create Shadow /AutoRetry=15 /For=$TaskFor"
  $WorkingDir = "%systemroot%\system32"
  
  $ScheduledAction = New-ScheduledTaskAction –Execute $Task -WorkingDirectory $WorkingDir -Argument $Argument
  $ScheduledTrigger = @()
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 07:00
  $ScheduledTrigger += New-ScheduledTaskTrigger -Daily -At 12:00
  $ScheduledSettings = New-ScheduledTaskSettingsSet -Compatibility V1 -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3) -Priority 5
  $ScheduledTask = New-ScheduledTask -Action $ScheduledAction -Trigger $ScheduledTrigger -Settings $ScheduledSettings
  Register-ScheduledTask $TaskName -InputObject $ScheduledTask -User "NT AUTHORITY\SYSTEM"
}

#All done! 
Write-Host -BackgroundColor Black -ForegroundColor Green "---------"
Write-Host -BackgroundColor Black -ForegroundColor Green "All done!"
Write-Host -BackgroundColor Black -ForegroundColor Green "---------"