﻿<#
  .Synopsis
    Reset ONE passwords in O365 domain
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then resets password for one selected user in O365.

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
$usern = Read-Host "Enter users mailadress" 
$passwd = Read-Host "Enter the new password"
Set-MsolUserPassword -UserPrincipalName $usern -NewPassword $passwd -ForceChangePassword $false 

# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com