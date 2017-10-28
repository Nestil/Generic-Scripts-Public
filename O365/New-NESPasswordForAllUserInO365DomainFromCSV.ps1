<#
  .Synopsis
    Reset passwords in O365 domain based on content from csv file
  
  .Description
    This simple script use the Connect-NESo365.ps1 to connect to Office 365. 
    And then resets passwords for selected user in O365.

  .Notes
    Author: Ron Kjernell - ron@nestil.se
    Requires Connect-NESO365.ps1

    To run this you will also need the following: 

    Microsoft Online Services Sign-in Assistant for IT-Professionals RTW
    http://go.microsoft.com/fwlink/?LinkID=286152 

    And: http://go.microsoft.com/fwlink/p/?linkid=236297 
    
    Read more aboute the MSOnline Module here: https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory?redirectedfrom=msdn

  .LINK
    http://www.nestil.se  
    https://github.com/Nestil/
#>
$Users = Import-Csv -Path C:\Repo\Generic-Scripts-Public\O365\CSV\Userlist.csv
$Username = $Users.Username
$Password = $Users.Password
C:\Repo\Functions-Public\Connect-NESO365.ps1

foreach ($User in $Users)
{
    Set-MsolUserPassword -UserPrincipalName $Username -NewPassword $Password -ForceChangePassword $false  
}

# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com