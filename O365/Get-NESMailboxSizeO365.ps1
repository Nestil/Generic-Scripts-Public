﻿<#
  .Synopsis
    Lists all mailboxes in domain and shows their mailbox sizes
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then lists all users in the domain you specify with their mailbox size. 

  .Notes
    Author: Ron Kjernell - ron@nestil.se
C:\Repo\Functions-Public\Connect-NESO365.ps1
Get-Mailbox | get-mailboxstatistics | ft displayname, totalitemsize 

# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com