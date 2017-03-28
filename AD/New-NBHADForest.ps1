<#
  .Synopsis
    This script installs RSAT Tools, ADDS, DNS and GPMC and adds a AD-Forest. 
    It reads information from C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se      .LINK    http://www.nestil.se      https://github.com/Nestil/#>

#install RSAT-AD-Tools 
$LogPath = “c:\Repo\Log\ADDSInstalllog.txt” 
New-Item $LogPath -ItemType file -Force 
$addsTools = “RSAT-AD-Tools” 
Add-WindowsFeature $addsTools 
Get-WindowsFeature | Where installed >>$LogPath


#Deploy ADDS, DNS and GPMC 

start-job -Name addFeature -ScriptBlock { 
Add-WindowsFeature -Name “ad-domain-services” -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name “dns” -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name “gpmc” -IncludeAllSubFeature -IncludeManagementTools } 
Wait-Job -Name addFeature 
Get-WindowsFeature | Where installed >>$LogPath


# Create the Forest, add Domain Controller 
[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
$domainname = $AD.AD.Domainname
$netbiosName = $AD.AD.Netbios 
Import-Module ADDSDeployment 
Install-ADDSForest -CreateDnsDelegation:$false `
-DatabasePath “C:\Windows\NTDS” `
-DomainMode $AD.AD.Domainmode `
-DomainName $domainname `
-DomainNetbiosName $netbiosName `
-ForestMode $AD.AD.Forestmode -InstallDns:$true `
-LogPath “C:\Windows\NTDS” `
-NoRebootOnCompletion:$false `
-SysvolPath “C:\Windows\SYSVOL” `
-Force:$true