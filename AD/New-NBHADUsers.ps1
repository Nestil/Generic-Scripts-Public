[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\AD.xml
[xml]$AD = Get-Content -Path C:\Repo\Generic-Scripts-Public\AD\XML\Customer.xml
Import-Module ActiveDirectory
$Netbiosname = $AD.AD.Netbios
$FirstOU = $AD.AD.FirstOU
$pwd = Read-Host "Skriv in lösenordet"

$Path = "OU=Users,OU=$FirstOU,DC=$Netbiosname,DC=local"
$Users = $Customer.Customer.User

foreach ($User in $Users)
{
   New-ADUser `
   -Name $User.Name `
   -Path $Path `
   -SamAccountName $User.SamAccountName `
   -UserPrincipalName $User.SamAccountName+'@'+$AD.AD.Domainname `
   -Givenname $User.GivenName `
   -Surname $User.Surname `
   -DisplayName $User.DisplayName `
   -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) `
   -ChangePasswordAtLogon $false  `
   -Enabled $true
   Add-ADGroupMember "TS Users" $User.SamAccountName;
}