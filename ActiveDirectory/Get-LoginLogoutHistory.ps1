cls
$Usr = 'xxxxxxxxx'

Get-ADDomainController -fi * | select -exp hostname | % {
    Write-Host $_

    $ParamsEvn = @{
        ‘Computername’ = $_
        ‘LogName’ = ‘Security’
        ‘FilterXPath’ = "*[EventData[Data[@Name='TargetUserName']='$Usr']]"
        }

        $temp = Get-WinEvent @ParamsEvn
        $Evnts  = $Evnts + $temp
}

$Evnts | Sort-Object -Descending -Property TimeCreated | foreach {$_}