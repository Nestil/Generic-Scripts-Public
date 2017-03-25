<#
  .Synopsis
    Lists all mailboxes which have active licenses on them and exports them to CSV or TXT
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then lists all mailboxes which have active licenses on them and exports them to c:\Temp\(and the filename you choose)  

  .Notes
    Author: Ron Kjernell - ron@nestil.se    Requires Connect-NESO365.ps1    To run this you will also need the following:     Microsoft Online Services Sign-in Assistant for IT-Professionals RTW    http://go.microsoft.com/fwlink/?LinkID=286152     And: http://go.microsoft.com/fwlink/p/?linkid=236297         Read more aboute the MSOnline Module here: https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory?redirectedfrom=msdn  .LINK    http://www.nestil.se      https://github.com/Nestil/#>
C:\Repo\Functions-Public\Connect-NESO365.ps1
New-Item -ItemType Directory -Path C:\Temp -Force
$Filename = Read-Host "Enter Filename"
Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" } | Select-Object UserPrincipalName, City, Country, Department, DisplayName, Firstname, Lastname | Export-Csv c:\Temp\$Filename -Encoding UTF8
#Remove Session
Remove-PSSession -ComputerName outlook.office365.com