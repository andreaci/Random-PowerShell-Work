<#
    .Description
        Download entitlement and parses license INI from it
    .Parameter License
        License number to download entitlement for
    .Parameter Debug
        Enables loginng of exceptions, which are otherwise suppressed
    .Outputs
        avg_license.ini file in workikng dir containing parsed license
#>

param($LicenseNumber,[switch]$Debug)

function ConvertFrom-Json
{
    <#
        .Description
            Deserializes JSON to PS object
            It does not support pipeline
        .Parameter InputObject
            String to be deserialized
        .Outputs
            Object containing deserialized data
    #>

    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        $InputObject
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
    $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer

    return $ser.DeserializeObject($InputObject)
}

$null = [Reflection.Assembly]::LoadWithPartialName( "System.Collections.Generic" );

function ConvertFrom-Base64($string) 
{
	<#
        .Synopsis
            returns decoded string from base64 encoded string
        .Description
            Should be used with url from browser for example in situations when u need to decod the url from failed installation
		.Parameter string
			the base64 UTF8 encoded string
        .Example
            $decodedString = ConvertFrom-Base64 $encodedString
    #>
	
	$bytes  = [System.Convert]::FromBase64String($string);
	$decoded = [System.Text.Encoding]::Default.GetString($bytes);

	return $decoded;
}

#Powershell version 3.0 or hihger is required
if ($PSVersionTable.PSVersion.Major -lt 3)
{
    Write-Host "ERROR: Unsupported version of Powershell (version 2.0 or lower) detected. Powershell version 3.0 or higher required. Go to`nhttps://www.microsoft.com/en-us/download/confirmation.aspx?id=34595 to download and update your Powershell (if applicable for your OS).`nTerminating." -ForegroundColor Red
    Exit
}

#Download the entitlement
try
{
    $InputEntitlement = Invoke-WebRequest -Uri 'https://rs.update.avg.com/gls/gms/entitlement.cfg' -UserAgent "AVGINET17-ASWINX64 170 BUILD=7637 LIC=$LicenseNumber" -Headers  @{'Accept-Encoding' = 'identity,deflate'
            'x-avg-id' = '0-0'} -Method 'GET'
}
catch
{
    Write-Host "ERROR: Couldn't download entitlement, check your network connection" -ForegroundColor Red
    if ($Debug) { Write-Host $_ -ForegroundColor Red }
    Exit
}

Write-Host "INFO: Loading downloaded entitlement..."

#Check validity of entitlement
if ($InputEntitlement -notmatch "\{`"data_version`".*`"license_json`".*")
{
    Write-Host "ERROR: Invalid server response check the license number." -ForegroundColor Red
    if ($Debug) { Write-Host $InputEntitlement  -ForegroundColor Red }
    Exit
}

#Get the license_json element from entitlement and decode it
Write-Host "INFO: Parsing downloaded entitlement..."
$LicenseJson = (ConvertFrom-Base64 (ConvertFrom-Json $InputEntitlement).products.licenses.license_json)

#Convert the resulting JSON to object
try
{
    $ParsedJson = ConvertFrom-Json $LicenseJson.Split(";")[0]
}
catch
{
    Write-Host "ERROR: Invalid license JSON" -ForegroundColor Red
    if ($Debug) { Write-Host $_ -ForegroundColor Red }
    Exit
}

#Get the license_ini element from entitlement and decode it
try
{
    $ParsedLicense = ConvertFrom-Base64 $ParsedJson.parameters.license_ini
}
catch
{
    Write-Host "ERROR: Invalid Base64 string in license_ini element" -ForegroundColor Red
    if ($Debug) { Write-Host $_ -ForegroundColor Red }
    Exit
}

Write-Host "INFO: Writing avg_license.ini..."
#Drop avg_license.ini file
try
{
    [System.IO.File]::WriteAllText("$PWD\avg_license.ini",$ParsedLicense,[System.Text.Encoding]::ASCII)
}
catch
{
    Write-Host "ERROR: Couldn't create $PWD\avg_license.ini" -ForegroundColor Red
    if ($Debug) { Write-Host $_ -ForegroundColor Red }
    Exit
}

"License file created successfuly: $PWD\avg_license.ini"
# SIG # Begin signature block
# MIIhcgYJKoZIhvcNAQcCoIIhYzCCIV8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDV66KG77dUnvKe
# cIY1SLOLbmuGIXoe5pZrW/YEZ47OY6CCD7UwggUwMIIEGKADAgECAhAECRgbX9W7
# ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBa
# Fw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
# ZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/l
# qJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fT
# eyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqH
# CN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+
# bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLo
# LFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIB
# yTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHow
# eDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwA
# AgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAK
# BghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7s
# DVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGS
# dQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6
# r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo
# +MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qz
# sIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHq
# aGxEMrJmoecYpJpkUe8wggU0MIIDHKADAgECAgphHLKKAAAAAAAmMA0GCSqGSIb3
# DQEBBQUAMH8xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAn
# BgNVBAMTIE1pY3Jvc29mdCBDb2RlIFZlcmlmaWNhdGlvbiBSb290MB4XDTExMDQx
# NTE5NDEzN1oXDTIxMDQxNTE5NTEzN1owZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEArQ4VzuRDgFyxh/O3YPlxEqWu3CaUiKr0zvUgOShYYAz4
# gNqpFZUyYTy1sSiEiorcnwoMgxd6j5Csiud5U1wxhCr2D5gyNnbM3t08qKLvavsh
# 8lJh358g1x/isdn+GGTSEltf+VgYNbxHzaE2+Wt/1LA4PsEbw4wz2dgvGP4oD7On
# g9bDbkTAYTWWFv5ZnIt2bdfxoksNK/8LctqeYNCOkDXGeFWHIKHP5W0KyEl8MZgz
# bCLph9AyWqK6E4IR7TkXnZk6cqHm+qTZ1Rcxda6FfSKuPwFGhvYoecix2uRXF8R+
# HA6wtJKmVrO9spftqqfwt8WoP5UW0P+hlusIXxh3TwIDAQABo4HLMIHIMBEGA1Ud
# IAQKMAgwBgYEVR0gADALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
# HQ4EFgQUReuir/SSy4IxLVGLp6chnfNtyA8wHwYDVR0jBBgwFoAUYvsKIVt/Q24R
# 2glUUGv10pZx8Z4wVQYDVR0fBE4wTDBKoEigRoZEaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9zb2Z0Q29kZVZlcmlmUm9vdC5j
# cmwwDQYJKoZIhvcNAQEFBQADggIBAFz1si0Czu0BtTUS2BP3qkAUx6FcoIpV7X5V
# 6mrEVxdv0EciQjZY78WsYcX2LFLOaubIDYXaszRCDqQCJRgmcrkqTqV+SxbyoOQM
# RJziTZr0dPD5J6ZpkDHCRGVDSMdIadD8hAnyhhQKwimWhX8R64cTF27T7Gv/HVeK
# sXsepaB86aJ6aOX6xrFh1nJj+jeRY4NVmfgdYU8Mb6P3vLEVKsyNheMUF+9+SUQ/
# sCLA8Ky+L9vhDIaw9FhcWhCpS83zRIpGUgg+CmIQ6UWVBLeLjUsHT1ANt7vn+4yi
# eHjGxTt2Y7LP5SGEWmb84Ex5g07PqO5wBYZYfMKc1zyjrTx+dmJch9DtfNXFWxQh
# 9L51onXS6eFa0CAweEFiTWtebhsXECRK2FiHddAV12K7/RhWZYQlYZd/qtSd9PNd
# baAxwuGeAqw+kMMyfugykDQW0IsUz5WszuWMVKJluL/tGGpXBz7T55pKLwgaBBxJ
# hxqK5hsIo2XYHDHFDZy6s2jd9FB2FgZ1/sQD59E+39yGLhACfmYSllNOevM2WHmx
# IELYlj81vj+O8pmXQ/XkDOE8aHKMjUnXWlK1c/t6NZQ6YbCEgsBIhcGXMtObcl+g
# 0jSPfvBGfPKMcpTHB7DXtbIwuBll8JyDJ7Cgq9Cicn4FD7Ou3blbm0K8wyZjRWuG
# 8R1GQ+3IMIIFRTCCBC2gAwIBAgIQCRjiMFePnyFKC7FlTbRE2DANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE4MDYwNzAwMDAwMFoXDTIxMDYx
# MTEyMDAwMFowgYExCzAJBgNVBAYTAlVTMRcwFQYDVQQIEw5Ob3J0aCBDYXJvbGlu
# YTEPMA0GA1UEBxMGTmV3dG9uMSMwIQYDVQQKExpBVkcgVGVjaG5vbG9naWVzIFVT
# QSwgSW5jLjEjMCEGA1UEAxMaQVZHIFRlY2hub2xvZ2llcyBVU0EsIEluYy4wggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCfaZ+r32uHah9xJiogKCNQ7CBb
# UzBIdVw/yrvwfacBwR8fFObb/LUPu5CqH5OnDEjEPx7plAu0ZKW9bL4AIH5Ky+cc
# JyTxncSeYQlFT6uWau4Kx9CixcyZduBCdZvgLSA2RE2B+aEfHycSYfG3hUj9vIVS
# f70IhG3+patXfTUyvXKmajoMcOLW0b2rirvd0fYrg9i0mUsDUL5k3driRk5GKmeD
# BkLa08MDhJg8zuPti2yc3fc1dkQu3jnLoVL7F1+3v0KAQ+qetP0WxWUOIZIrD0Mh
# OMBPZpEA4AT1uVcTqcGOCualDF1ZJ6eR4Sgc04/XnkbY5jhDDmHlxZmsgEZLAgMB
# AAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAdBgNV
# HQ4EFgQU3q0CbtLqOlU0CuEa6JS371hzdnowDgYDVR0PAQH/BAQDAgeAMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDBMBgNVHSAE
# RTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEEeDB2MCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTgYIKwYBBQUHMAKGQmh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURDb2Rl
# U2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQDV
# 0JofFXx5GN1woXp8pWJn8Ah4Dy/P2Xyy1OVvZ3MSCjldmMKvkyLdliSEgo6fIiOV
# s4dk8AIdLuYZ/JQJjMaoid1bIBrYrQg6LWwgSArIb/cdvfunFOCqoiqBa6T37pts
# DnkJ4OCU3EhjDJbu16pqEpMOa27UTl2Lrf31wO+uYocjgZdE8j4lrzHdu8uUc3Cu
# TS/xLudAOBB4jCYjvXyOJfD/L1RaiTyVGMOUqvocEKS+IlY6YykWp/0GJbqZTFIB
# EomWMQECOAF+NmiXCn01uUb8GK6KFV5qOWFU+yHyhjicwHwQ2nvE2w/UgM2bR/qi
# hUniIdIKh9nNQrb5jfKnMYIREzCCEQ8CAQEwgYYwcjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
# MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBD
# QQIQCRjiMFePnyFKC7FlTbRE2DANBglghkgBZQMEAgEFAKCBkjAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAm
# BgorBgEEAYI3AgEMMRgwFqEUgBJodHRwOi8vd3d3LmF2Zy5jb20wLwYJKoZIhvcN
# AQkEMSIEIAUw23ylZ6Sk6aYACvB9XbBITAd94EoXM4K+cVRTh1riMA0GCSqGSIb3
# DQEBAQUABIIBAGxeXGhuBmwlruLU1TMBbn5ehMfEOLyzRKQtwa59YINL3rkAl5Rs
# pE+MQLLaZ67OvWJTMTJEblMHuZqDFj+U5hM6nMxyRNLudPBZLoLLzG1eAFyqv28N
# 5KPEiQeFr4sbLSid4Lrx+X7vh6MjcoY//NaLIRXdMuhIoyksD5vn2/F7oSo8QDGV
# +RnICMZLA9cp0D/0roK1y93K0iMYUIH0z/pdsUxHnUlCMM4TjRbSEn6U2YQ94kPl
# PC56j+YWYr/z7Sf6DWV7w7DtiSSMlxWqO9eB9XH0F4RgZ5t147XBvk4m6AEqLO5a
# RVAA7v89tAMDqkF2OgyEvjezkK+2flwnWnWhgg7IMIIOxAYKKwYBBAGCNwMDATGC
# DrQwgg6wBgkqhkiG9w0BBwKggg6hMIIOnQIBAzEPMA0GCWCGSAFlAwQCAQUAMHcG
# CyqGSIb3DQEJEAEEoGgEZjBkAgEBBglghkgBhv1sBwEwMTANBglghkgBZQMEAgEF
# AAQgTkc9W0Fd++OUkL1ac9++qZOBqAXuVNFte0NLaCT7BkUCEE+OP/tsXnsfGpMC
# IC6JNJQYDzIwMTgxMDA0MTI0MzI5WqCCC7swggaCMIIFaqADAgECAhAJwPxGyARC
# E7VZi68oT05BMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNV
# BAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcN
# MTcwMTA0MDAwMDAwWhcNMjgwMTE4MDAwMDAwWjBMMQswCQYDVQQGEwJVUzERMA8G
# A1UEChMIRGlnaUNlcnQxKjAoBgNVBAMTIURpZ2lDZXJ0IFNIQTIgVGltZXN0YW1w
# IFJlc3BvbmRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ6VmGo0
# O3MbqH78x74paYnHaCZGXz2NYnOHgaOhnPC3WyQ3WpLU9FnXdonk3NUn8NVmvAru
# tCsxZ6xYxUqRWStFHgkB1mSzWe6NZk37I17MEA0LimfvUq6gCJDCUvf1qLVumyx7
# nee1Pvt4zTJQGL9AtUyMu1f0oE8RRWxCQrnlr9bf9Kd8CmiWD9JfKVfO+x0y//QR
# oRMi+xLL79dT0uuXy6KsGx2dWCFRgsLC3uorPywihNBD7Ds7P0fE9lbcRTeYtGt0
# tVmveFdpyA8JAnjd2FPBmdtgxJ3qrq/gfoZKXKlYYahedIoBKGhyTqeGnbUCUodw
# ZkjTju+BJMzc2GUCAwEAAaOCAzgwggM0MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMB
# Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMIIBvwYDVR0gBIIBtjCCAbIw
# ggGhBglghkgBhv1sBwEwggGSMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBl
# ACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBu
# AHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0
# AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0
# AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBl
# AG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5
# ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABl
# AHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCGSAGG/WwD
# FTAfBgNVHSMEGDAWgBT0tuEgHf4prtLkYaWyoiWyyBc1bjAdBgNVHQ4EFgQU4acy
# Su4BISh9VNXyB5JutAcPPYcwcQYDVR0fBGowaDAyoDCgLoYsaHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMIGFBggrBgEFBQcB
# AQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggr
# BgEFBQcwAoZDaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hB
# MkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAQEA
# HvBBgjKu7fG0NRPcUMLVl64iIp0ODq8z00z9fL9vARGnlGUiXMYiociJUmuajHNc
# 2V4/Mt4WYEyLNv0xmQq9wYS3jR3viSYTBVbzR81HW62EsjivaiO1ReMeiDJGgNK3
# ppki/cF4z/WL2AyMBQnuROaA1W1wzJ9THifdKkje2pNlrW5lo5mnwkAOc8xYT49F
# KOW8nIjmKM5gXS0lXYtzLqUNW1Hamk7/UAWJKNryeLvSWHiNRKesOgCReGmJZATT
# XZbfKr/5pUwsk//mit2CrPHSs6KGmsFViVZqRz/61jOVQzWJBXhaOmnaIrgEQ9Nv
# aDU2ehQ+RemYZIYPEwwmSjCCBTEwggQZoAMCAQICEAqhJdbWMht+QeQF2jaXwhUw
# DQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNl
# cnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEy
# MDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBB
# c3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAL3QMu5LzY9/3am6gpnFOVQoV7YjSsQOB0UzURB90Pl9TWh+57ag
# 9I2ziOSXv2MhkJi/E7xX08PhfgjWahQAOPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpV
# fgsnfsCi9aDg3iI/Dv9+lfvzo7oiPhisEeTwmQNtO4V8CdPuXciaC1TjqAlxa+DP
# IhAPdc9xck4Krd9AOly3UeGheRTGTSQjMF287DxgaqwvB8z98OpH2YhQXv1mblZh
# JymJhFHmgudGUP2UKiyn5HU+upgPhH+fMRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN
# 7wZC/aJTKk+FHcQdPK/P2qwQ9d2srOlW/5MCAwEAAaOCAc4wggHKMB0GA1UdDgQW
# BBT0tuEgHf4prtLkYaWyoiWyyBc1bjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYun
# pyGd823IDzASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYD
# VR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBQBgNVHSAESTBHMDgGCmCG
# SAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29t
# L0NQUzALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggEBAHGVEulRh1Zpze/d
# 2nyqY3qzeM8GN0CE70uEv8rPAwL9xafDDiBCLK938ysfDCFaKrcFNB1qrpn4J6Jm
# vwmqYN92pDqTD/iy0dh8GWLoXoIlHsS6HHssIeLWWywUNUMEaLLbdQLgcseY1jxk
# 5R9IEBhfiThhTWJGJIdjjJFSLK8pieV4H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJ
# qPVrlsD0WGkNfMgBsbkodbeZY4UijGHKeZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6
# DC0rbaLEfrvEJStHAgh8Sa4TtuF8QkIoxhhWz0E0tmZdtnR79VYzIi8iNrJLokqV
# 2PWmjlIxggJNMIICSQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhE
# aWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBAhAJwPxGyARC
# E7VZi68oT05BMA0GCWCGSAFlAwQCAQUAoIGYMBoGCSqGSIb3DQEJAzENBgsqhkiG
# 9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMTgxMDA0MTI0MzI5WjAvBgkqhkiG9w0B
# CQQxIgQgrAYQP/anK3T06DQr0K4HK7llwlUX3Gw+jFOfnI+Pk6kwKwYLKoZIhvcN
# AQkQAgwxHDAaMBgwFgQUQAGRR1yYiR3roQSvRwkbXrbUy8swDQYJKoZIhvcNAQEB
# BQAEggEAWMh6Rm3TbMMAdRPr6BTvhZuyhCuER0VxctJM8zK2m1GBJOFiBzBJ4OQl
# V0bFIPcfq/Ul4EZ/tJOYbH9GIL1nyNuCyH5VuGg25oJGpKDVw4hDrlGxun3tZHyd
# /dwXlYy+aXUQZhEqCYWJledUfaZmMRlsMe6jXugE+XtjJpoMoOcTuHOWQztngepp
# zf/oBh24+0lRDrSisnYzGKDykyoHKtLr3KhqklBuc1sBfrXk3qU01OQiRC5I15zq
# vEIbIXlFN5P7mzZckxecfNAC+ax6FR1zzPaiIiPT7G7tZ8nDZxaRBCMnVLv/PxMk
# bjAtgdn9I+KW2D9Z5Jwgk+bmrL7Kqw==
# SIG # End signature block
