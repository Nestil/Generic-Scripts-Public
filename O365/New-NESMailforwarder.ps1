C:\Repo\Functions-Public\Connect-NESO365.ps1

Set-Mailbox user@maildomain -ForwardingsmtpAddress forwardedaddress@maildomain -DeliverToMailboxAndForward $True


# Remove session when done.
Remove-PSSession -ComputerName outlook.office365.com