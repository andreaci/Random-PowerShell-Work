# generate a new RSA / SSH key for the current user, using the email address
# from the AD/LDAP data.
#
# Used to add this key in gitlab


$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
[System.IO.Directory]::CreateDirectory("$env:USERPROFILE\.ssh")

if (-not (Test-Path $keyPath)) {
    # Get primary proxyAddress via ADSI
    $adsi = [ADSI]"LDAP://$(([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name)"
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($adsi)

    $searcher.Filter = "(&(objectClass=user)(sAMAccountName=$env:USERNAME))"
    $searcher.PropertiesToLoad.Add("proxyAddresses") | Out-Null

    $result = $searcher.FindOne()

    $email = $result.Properties["proxyaddresses"] |
    Where-Object { $_ -cmatch '^SMTP:' } |
    ForEach-Object { $_ -replace '^SMTP:' }

    if (-not $email) {
        throw "Primary proxyAddress not found for user $env:USERNAME"
    }

    ssh-keygen -q -o -t rsa -b 4096 -C "$email" `
      -f "$keyPath" `
      -N '""'

}

Get-Content "$keyPath.pub"
