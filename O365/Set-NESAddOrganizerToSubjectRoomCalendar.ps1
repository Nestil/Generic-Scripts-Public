Set-ExecutionPolicy RemoteSigned

$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange-ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session

cls

Get-Mailbox -Filter '(RecipientTypeDetails -eq "RoomMailBox")' | Select Name

$RoomMailbox=Read-Host "Please enter the room to edit"

Set-MailboxFolderPermission -AccessRights LimitedDetails -Identity ${RoomMailbox}:\calendar -User default

Set-CalendarProcessing -Identity $RoomMailbox -AddOrganizerToSubject $true -DeleteComments $false -DeleteSubject $false

