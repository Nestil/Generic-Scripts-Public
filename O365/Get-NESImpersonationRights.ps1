<#
  .Synopsis
   Gives the specified user impersonation rights to the entire O365 domain
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then Give the specified user impersonation rights to the entire O365 domain

  .Notes
    Author: Ron Kjernell - ron@nestil.se    Requires Connect-NESO365.ps1    To run this you will also need the following:     Microsoft Online Services Sign-in Assistant for IT-Professionals RTW    http://go.microsoft.com/fwlink/?LinkID=286152     And: http://go.microsoft.com/fwlink/p/?linkid=236297         Read more aboute the MSOnline Module here: https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory?redirectedfrom=msdn  .LINK    http://www.nestil.se      https://github.com/Nestil/#>
C:\Repo\Functions-Public\Connect-NESO365.ps1
#Enable Impersonation and Organizational Customization
$nestiladmin = Read-Host "Enter adminaccount to get impersonation rights"
Enable-OrganizationCustomization
New-ManagementRoleAssignment -Role: ApplicationImpersonation -User: $nestiladmin 

#Remove Session
Remove-PSSession -ComputerName outlook.office365.com