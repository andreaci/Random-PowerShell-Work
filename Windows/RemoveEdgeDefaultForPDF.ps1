# This script will check the registry for all file associations that might be set to open by default by Edge browser
# For those who do not want Edge browser opening pdf files or anything else by default


# Identify the edge application class
$Packages = "HKCU:SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages"
$edge = Get-ChildItem $Packages -Recurse -include "MicrosoftEdge"

# Specify the paths to the file and URL associations
$FileAssocKey = Join-Path $edge.PSPath Capabilities\FileAssociations
$URLAssocKey = Join-Path $edge.PSPath Capabilities\URLAssociations

# get the software classes for the file and URL types that Edge will associate
$FileTypes = Get-Item $FileAssocKey
$URLTypes = Get-Item $URLAssocKey

$FileAssoc = Get-ItemProperty $FileAssocKey
$URLAssoc = Get-ItemProperty $URLAssocKey

$Associations = @()
$Filetypes.Property | foreach {$Associations += $FileAssoc.$_}
$URLTypes.Property | foreach {$Associations += $URLAssoc.$_}

# add registry values in each software class to stop edge from associating as the default
foreach ($Association in $Associations)
     {
     $Class = Join-Path HKCU:SOFTWARE\Classes $Association
     #if (Test-Path $class)
     #   {write-host $Association}
     # Get-Item $Class
     Set-ItemProperty $Class -Name NoOpenWith -Value ""
     Set-ItemProperty $Class -Name NoStaticDefaultVerb -Value ""
     }
 