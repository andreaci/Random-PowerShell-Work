
$disabledmailboxes = @()
$disabledmailboxes = Get-MailboxStatistics -Database <database> | where {$_.DisconnectReason -eq "Disabled"} 

foreach ($mailbox in $disabledmailboxes) {
#define variables
$strIdentity = $mailbox.DisplayName
$strDatabase = $mailbox.database

Remove-StoreMailbox -Database $strDatabase -Identity $strIdentity -MailboxState Disabled}