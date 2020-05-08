$Date = Get-Date
Import-Module ActiveDirectory

$users = Get-Aduser -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress -SearchBase "CN=Users,DC=softeam,DC=local"   -filter { (Enabled -eq 'True')  } 


$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

$resultArray = @()


# Process Each User for Password Expiry
foreach ($user in $users)
{
	$Name = $user.Name 
	$PasswordExpired = $user.PasswordExpired
	$PasswordNeverExpires = $user.PasswordNeverExpires


	$passwordSetDate = (Get-ADUser $user -properties * | ForEach-Object { $_.PasswordLastSet })
	
	$PasswordPol = (Get-ADUserResultantPasswordPolicy $user)
	if (($PasswordPol) -ne $null)
	{
		$maxPasswordAgeCurrent = ($PasswordPol).MaxPasswordAge
	}
	else
    {
        $maxPasswordAgeCurrent = $maxPasswordAge
    }

	$expireson = $passwordsetdate + $maxPasswordAgeCurrent
	$today = (get-date)
	#Gets the count on how many days until the password expires and stores it in the $daystoexpire var
	$daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days



    $temp = New-Object System.Object
    $temp | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
    $temp | Add-Member -MemberType NoteProperty -Name "PasswordExpired" -Value $PasswordExpired
    $temp | Add-Member -MemberType NoteProperty -Name "PasswordNeverExpires" -Value $PasswordNeverExpires
    $temp | Add-Member -MemberType NoteProperty -Name "daystoexpire" -Value $daystoexpire
    $temp | Add-Member -MemberType NoteProperty -Name "passwordSetDate" -Value $passwordSetDate
    $temp | Add-Member -MemberType NoteProperty -Name "maxPasswordAgeCurrent" -Value $maxPasswordAgeCurrent
    $temp | Add-Member -MemberType NoteProperty -Name "expireson" -Value $expireson

$resultArray = $resultArray+ $temp

    
}

$resultArray  | ft