<#
  .Synopsis
    Imports users to Office 365 from CSV or TXT file
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then imports users from CSV or TXT file.  

  .Notes
    Author: Ron Kjernell - ron@nestil.se    Requires Connect-NESO365.ps1    To run this you will also need the following:     Microsoft Online Services Sign-in Assistant for IT-Professionals RTW    http://go.microsoft.com/fwlink/?LinkID=286152     And: http://go.microsoft.com/fwlink/p/?linkid=236297         Read more aboute the MSOnline Module here: https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory?redirectedfrom=msdn  .LINK    http://www.nestil.se      https://github.com/Nestil/#>
C:\Repo\Functions-Public\Connect-NESO365.ps1
#Import from CSV
$Path = Read-Host "Enter path to csv or txt file"
$users = Import-Csv $Path

$users | ForEach-Object {

New-MsolUser -UserPrincipalName $_.UserPrincipalName -City $_.city -Country $_.Country -Department $_.Department -DisplayName $_.DisplayName -FirstName $_.FirstName -LastName $_.LastName }

#Remove Session
Remove-PSSession -ComputerName outlook.office365.com