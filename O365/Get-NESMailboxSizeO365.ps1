<#
  .Synopsis
    Lists all mailboxes in domain and shows their mailbox sizes
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then lists all users in the domain you specify with their mailbox size. 

  .Notes
    Author: Ron Kjernell - ron@nestil.se    Requires Connect-NESO365.ps1    To run this you will also need the following:     Microsoft Online Services Sign-in Assistant for IT-Professionals RTW    http://go.microsoft.com/fwlink/?LinkID=286152     And: http://go.microsoft.com/fwlink/p/?linkid=236297         Read more aboute the MSOnline Module here: https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory?redirectedfrom=msdn  .LINK    http://www.nestil.se      https://github.com/Nestil/#>
C:\Repo\Functions-Public\Connect-NESO365.ps1
Get-Mailbox | get-mailboxstatistics | ft displayname, totalitemsize 

# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com