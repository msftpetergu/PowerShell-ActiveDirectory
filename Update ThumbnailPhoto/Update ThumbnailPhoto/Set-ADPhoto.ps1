# Author: Peter Gu (petergu@microsoft.com)
# Date: 3/4/2017
# Version: 1.0

Param(
	#[Parameter(Mandatory=$False)][string]$Domain,
	[Parameter(Mandatory=$True,Position=1)][string]$Alias,
	[Parameter(Mandatory=$False,Position=2)][string]$Photo = $Alias + '.jpg'
)

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root

$search.Filter = "(&(objectclass=user)(objectcategory=person)(samAccountName=$Alias))"
$result = $search.FindOne()

Function EventTime {
	return "[" + (Get-Date -Format 'MM/dd/yyyy hh:mm:ss') + "] "
}

if (!(Test-Path $Photo)) {
	Write-Host ((EventTime) + "File doesn't exist.") -ForegroundColor Red
	break
}

if ($result.count -eq 1) {
	$user = $result.GetDirectoryEntry()
	[byte[]]$PictureContent = Get-Content $Photo -encoding byte
	$user.put("thumbnailPhoto",  $PictureContent)
	$user.setinfo()
	Write-Host ((EventTime) + "Picture updated for " + $user.displayname + ".") -ForegroundColor Green
}
else {
	Write-Host ((EventTime) + $Alias + "does not exist.") -ForegroundColor Red
}