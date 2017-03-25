﻿<#
  .Synopsis
    Lists all mailboxes which have active licenses on them and exports them to CSV or TXT
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then lists all mailboxes which have active licenses on them and exports them to c:\Temp\(and the filename you choose)  

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
New-Item -ItemType Directory -Path C:\Temp -Force
$Filename = Read-Host "Enter Filename"
Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" } | Select-Object UserPrincipalName, City, Country, Department, DisplayName, Firstname, Lastname | Export-Csv c:\Temp\$Filename -Encoding UTF8
#Remove Session
Remove-PSSession -ComputerName outlook.office365.com