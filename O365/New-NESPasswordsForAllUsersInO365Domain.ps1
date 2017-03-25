﻿<#
  .Synopsis
    Reset ALL passwords in O365 domain
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then resets all the users in the office 365 domain, be certain to fill in the nestiladmin account when it asks, in the form of nestiladmin@userdomain.domain

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
$passwd = Read-Host "Enter the new password for the normal users"
$nestiladm = Read-Host "Enter the full username for nestiladmin@"
$nestiladmpasswd = Read-Host "Enter the password for nestiladmin@"
Get-msoluser |set-msoluserpassword -newpassword $passwd -forcechangepassword $false
Set-MsolUserPassword -UserPrincipalName $nestiladm -NewPassword $nestiladmpasswd -ForceChangePassword $false 

# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com