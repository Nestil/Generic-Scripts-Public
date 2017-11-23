<#
  .Synopsis
    This script will create the AD Structure, add all the OU's, adds adminusers to the ou's. 
    Creates the GPO's and imports the correct GPO's from c:\Repo\Generic-Scripts-Public\AD\GPO\
    Then links the GPO's to Correct OU and fixes paths for a certain GPO
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
         
  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>



#Add the OU Structure
New-ADOrganizationalUnit -Name $FirstOU
New-ADOrganizationalUnit -Name Groups -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name Servers -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name RDS -Path "OU=Servers,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name Nestil -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name Users -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name Konsulter -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"

#Add Groups
New-ADGroup -Name "Ekonomi" -Groupscope Global -Path "OU=Groups,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADGroup -Name "Ledning" -Groupscope Global -Path "OU=Groups,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADGroup -Name "TS Users" -Groupscope Global -Path "OU=Groups,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADGroup -Name "Gemensam" -Groupscope Global -Path "OU=Groups,OU=$FirstOU,DC=$Netbiosname,DC=local"

#Lägg till alla NestilAdmins som Domain Admins
#Version 1.1 MW/RK
$Path = "OU=Nestil,OU=$FirstOU,DC=$Netbiosname,DC=local"
$Users = $AD.AD.NestilUsers.User

foreach ($User in $Users)
{
   New-ADUser `
    -Name $User.UserName `
    -Path $Path `
    -SamAccountName  $User.SamAccountName `
    -DisplayName $User.DisplayName `
    -AccountPassword (ConvertTo-SecureString $Nestilpwd -AsPlainText -Force) `
    -ChangePasswordAtLogon $false  `
    -Enabled $true
   Add-ADGroupMember "Domain Admins" $User.SamAccountName;
}

#Add Empty GPO's

New-GPO -Name "Domain Controller Settings - Default"
New-GPO -Name "Domain Controller Settings - PDC Specific Tasks"
New-GPO -Name "Domain Server Settings - Default"
New-GPO -Name "Server Settings - RDP"
New-GPO -Name "TS Lockdown"
New-GPO -Name "Outlook Fix"
New-GPO -Name "Outlook Autodiscover Regfix"
New-GPO -Name "Mappa Enheter"
New-GPO -Name "Common Firewall rules"

#Import GPO 
Import-GPO -BackupGPOName "Domain Controller Settings - Default" -TargetName "Domain Controller Settings - Default" -Path C:\Repo\Generic-Scripts-Public\AD\GPO 
Import-GPO -BackupGPOName "Domain Controller Settings - PDC Specific Tasks" -TargetName "Domain Controller Settings - PDC Specific Tasks" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Domain Server Settings - Default" -TargetName "Domain Server Settings - Default" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Server Settings - RDP" -TargetName "Server Settings - RDP" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "TS Lockdown"-TargetName "TS Lockdown" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Outlook Fix" -TargetName "Outlook Fix" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Outlook autodiscover regfix" -TargetName "Outlook Autodiscover Regfix"  -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Mappa Enheter" -TargetName "Mappa Enheter" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Common Firewall rules" -TargetName "Common Firewall rules" -Path C:\Repo\Generic-Scripts-Public\AD\GPO


#Link GPO to OU's
New-GPLink -Name "Domain Controller Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Controller Settings - PDC Specific Tasks" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
# Already linked by default - New-GPLink -Name "Domain Controller Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Server Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Outlook Fix" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Mappa Enheter" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "TS Lockdown" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Outlook Autodiscover Regfix" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Mappa Enheter" -Target "$Path"
New-GPLink -Name "Server Settings - RDP" -Target "OU=RDS,OU=Servers,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Server Settings - Default" -Target "OU=Servers,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Common Firewall rules" -Target "OU=$FirstOU,DC=$Netbiosname,DC=local"



sleep 120 

# Change Path to bginfo files in Domain Server Settings Default
$GpoGetInfo = get-gpo -Name "Domain Server Settings - Default" 
$GpoId = "{"+$GpoGetInfo.Id+"}"
$GpoPath = '\\'+$Domainname+'\SYSVOL\'+$Domainname+'\Policies\'+$gpoid+'\Machine\Preferences\Files\Files.xml'
[xml]$GpoXml = Get-Content -Path $GpoPath
$Newcustomfilepath = '\\'+$Domainname+'\SYSVOL\'+$Domainname+'\scripts\bginfo\Custom.bgi'
$Newbginfofilepath = '\\'+$Domainname+'\SYSVOL\'+$Domainname+'\scripts\bginfo\Bginfo.exe'

$GpoCustom = $GpoXml.Files.File.properties | where {$_.fromPath -eq '\\kjernell.local\SYSVOL\kjernell.local\scripts\bginfo\Custom.bgi'}
$GpoBginfo = $GpoXml.Files.File.properties | where {$_.fromPath -eq '\\kjernell.local\SYSVOL\kjernell.local\scripts\bginfo\Bginfo.exe'}
$GpoCustom.fromPath = $Newcustomfilepath
$GpoBginfo.fromPath = $Newbginfofilepath
$GpoXml.Save($GpoPath)

sleep 120

#Add Shared folders to GPO
$ADGroupGemensam = Get-ADGroup -Identity Gemensam
$ADGroupEkonomi = Get-ADGroup -Identity Ekonomi
$ADGroupLedning = Get-ADGroup -Identity Ledning

$GpoShareName = get-gpo -Name "Mappa Enheter" 
$GpoShareId = "{"+$GpoShareName.Id+"}"
$GpoSharePath = '\\'+$Domainname+'\SYSVOL\'+$Domainname+'\Policies\'+$GpoShareID+'\User\Preferences\Drives\Drives.xml'
[xml]$GpoShareXml = Get-Content -Path $GpoSharePath

$GpoShareEkonomi = $GpoShareXml.Drives.Drive | where {$_.name -eq 'E:'}
$GpoShareNewEkonomiPath = '\\'+$FSName+'\Ekonomi$'

$GpoShareLedning = $GpoShareXml.Drives.Drive | where {$_.name -eq 'L:'}
$GpoShareNewLedningPath = '\\'+$FSName+'\Ledning$'

$GpoShareGemensam = $GpoShareXml.Drives.Drive | where {$_.name -eq 'G:'}
$GpoShareNewGemensamPath = '\\'+$FSName+'\Gemensam$'
 
$GpoShareEkonomiFilterPath = $GpoShareEkonomi.Filters.FilterGroup | where {$_.name -eq 'KJERNELL\Ekonomi$'}
$GpoShareLedningFilterPath = $GpoShareLedning.Filters.FilterGroup | where {$_.name -eq 'KJERNELL\Ledning'}
$GpoShareGemensamFilterPath = $GpoShareGemensam.Filters.FilterGroup | where {$_.name -eq 'KJERNELL\Gemensam'}

$GpoShareEkonomi.Properties.path = $GpoShareNewEkonomiPath
$GpoShareEkonomiFilterPath.name = $Netbiosname+'\Ekonomi'
$GpoShareEkonomiFilterPath.sid = $ADGroupEkonomi.SID.Value

$GpoShareLedning.Properties.path = $GpoShareNewLedningPath
$GpoShareLedningFilterPath.name = $Netbiosname+'\Ledning'
$GpoShareLedningFilterPath.sid = $ADGroupLedning.SID.Value

$GpoShareGemensam.Properties.path = $GpoShareNewGemensamPath
$GpoShareGemensamFilterPath.name = $Netbiosname+'\Gemensam'
$GpoShareGemensamFilterPath.sid = $ADGroupGemensam.SID.Value

$GpoShareXml.Save($GpoSharePath)