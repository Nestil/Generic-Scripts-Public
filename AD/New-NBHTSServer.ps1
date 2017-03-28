<#
  .Synopsis
    This script sdds all the OU's, adds adminusers to the ou's. 
    Creates the GPO's and imports the correct GPO's from c:\Repo\Generic-Scripts-Public\AD\GPO\
    Then links the GPO's to Correct OU
  
  .Notes
    Author: Ron Kjernell - ron@nestil.se        Things to add in the future: Create the shares and set correct rights on these.         .LINK    http://www.nestil.se      https://github.com/Nestil/#>


[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
Import-Module ActiveDirectory
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU

Add-WindowsFeature -Name "Search-Service" 