﻿<#
  .Synopsis
   Gives the specified user impersonation rights to the entire O365 domain
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then Give the specified user impersonation rights to the entire O365 domain

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
#Enable Impersonation and Organizational Customization
$nestiladmin = Read-Host "Enter adminaccount to get impersonation rights"
Enable-OrganizationCustomization
New-ManagementRoleAssignment -Role: ApplicationImpersonation -User: $nestiladmin 

#Remove Session
Remove-PSSession -ComputerName outlook.office365.com