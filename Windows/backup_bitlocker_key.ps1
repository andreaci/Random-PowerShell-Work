$drives = Get-PSDrive -PSProvider FileSystem | select @{name="Name"; expression={ $_.Name+":"}}

foreach ($drive in $drives){
 
    #Enable-Bitlocker -MountPoint $drive.Name -EncryptionMehod -UsedSpaceOnly -PasswordProtector -SkipHardwareTest
    
    $BitVolume = Get-BitLockerVolume -MountPoint $drive.Name
    $RecoveryKey = $BitVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

    Backup-BitLockerKeyProtector -MountPoint $drive.Name -KeyProtectorId $RecoveryKey.KeyProtectorID
    BackupToAAD-BitLockerKeyProtector -MountPoint $drive.Name -KeyProtectorId $RecoveryKey.KeyProtectorID
}
