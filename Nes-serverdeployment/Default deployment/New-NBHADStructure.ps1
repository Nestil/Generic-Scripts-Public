<#
  .Synopsis
    This script sdds all the OU's, adds adminusers to the ou's. 
    Creates the GPO's and imports the correct GPO's from c:\Repo\Generic-Scripts-Public\AD\GPO\
    Then links the GPO's to Correct OU
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se
    
    Things to add in the future: Create the shares and set correct rights on these. 
      
  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>


[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
Import-Module ActiveDirectory
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU
$Nestilpwd = Read-Host "Skriv in lösenordet för nestiladmins"

#Add Windows Search and Print Service tools
#Add-WindowsFeature -Name "Search-Service"
#Add-WindowsFeature -Name "RSAT-Print-Services" 

#Add the OU Structure
New-ADOrganizationalUnit -Name $FirstOU
New-ADOrganizationalUnit -Name Groups -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
New-ADOrganizationalUnit -Name Servers -Path "OU=$FirstOU,DC=$Netbiosname,DC=local"
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

#Import GPO 
Import-GPO -BackupGPOName "Domain Controller Settings - Default" -TargetName "Domain Controller Settings - Default" -Path C:\Repo\Generic-Scripts-Public\AD\GPO 
Import-GPO -BackupGPOName "Domain Controller Settings - PDC Specific Tasks" -TargetName "Domain Controller Settings - PDC Specific Tasks" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Domain Server Settings - Default" -TargetName "Domain Server Settings - Default" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Server Settings - RDP" -TargetName "Server Settings - RDP" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "TS Lockdown"-TargetName "TS Lockdown" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Outlook Fix" -TargetName "Outlook Fix" -Path C:\Repo\Generic-Scripts-Public\AD\GPO
Import-GPO -BackupGPOName "Outlook autodiscover reg fix" -TargetName "Outlook Autodiscover Regfix"  -Path C:\Repo\Generic-Scripts-Public\AD\GPO

#Link GPO to OU's
New-GPLink -Name "Domain Controller Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Controller Settings - PDC Specific Tasks" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Controller Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Server Settings - Default" -Target "OU=Domain Controllers,DC=$Netbiosname,DC=local"
New-GPLink -Name "Outlook Fix" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Mappa Enheter" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "TS Lockdown" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Outlook Autodiscover Regfix" -Target "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Mappa Enheter" -Target "$Path"
New-GPLink -Name "Server Settings - RDP" -Target "OU=Servers,OU=$FirstOU,DC=$Netbiosname,DC=local"
New-GPLink -Name "Domain Server Settings - Default" -Target "OU=Servers,OU=$FirstOU,DC=$Netbiosname,DC=local"