$domain = "@coso.it"
$group = "NominalUsers"

$groupDN = Get-ADGroup $group | Select-Object -ExpandProperty DistinguishedName
$users = Get-ADUser -Filter {Memberof -eq $groupDN} -Properties samAccountName, EmailAddress | select samAccountName, EmailAddress

foreach($user in $users){
    set-aduser  -Identity "$($user.samAccountName)" -EmailAddress "$($user.samAccountName)$($domain)"
    echo "FOR USER: $($user.samAccountName) >>> $($user.samAccountName)$($domain)"
}