﻿<#
  .Synopsis
    Imports users to Office 365 from CSV or TXT file
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then imports users from CSV or TXT file.  

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
#Import from CSV
$Path = Read-Host "Enter path to csv or txt file"
$users = Import-Csv $Path

$users | ForEach-Object {

New-MsolUser -UserPrincipalName $_.UserPrincipalName -City $_.city -Country $_.Country -Department $_.Department -DisplayName $_.DisplayName -FirstName $_.FirstName -LastName $_.LastName }

#Remove Session
Remove-PSSession -ComputerName outlook.office365.com