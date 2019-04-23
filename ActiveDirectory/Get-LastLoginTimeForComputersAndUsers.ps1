$comps =Get-ADComputer -Filter  * -Properties lastlogondate,operatingsystem,OperatingSystemVersion,enabled,description | select @{Name="Type"; Expression={"COMPUTER"}}, @{Name="SamAccountName"; Expression=name},name,description, enabled,operatingsystem,OperatingSystemVersion,lastlogondate
$users =Get-ADuser      -Filter * -Properties LastLogonTimeStamp, enabled,description                                  | select @{Name="Type"; Expression={"USER"    }}, SamAccountName                           ,Name,description, enabled,@{Name="operatingsystem"; Expression={"-"}} ,@{Name="OperatingSystemVersion"; Expression={"-"}},@{Name="lastlogondate"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}                         

$comps+$users | FT

