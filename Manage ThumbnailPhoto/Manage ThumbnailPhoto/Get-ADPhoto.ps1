# Author: Peter Gu (petergu@microsoft.com)
# Date: 3/4/2017
# Version: 1.0

Param(
	#[Parameter(Mandatory=$False)][string]$Domain,
	[Parameter(Mandatory=$True,Position=1)][string]$Alias,
	[Parameter(Mandatory=$False,Position=2)][string]$Photo = $Alias + '.jpg'
)

if (Test-Path $Photo) {
	$PromptWindow = new-object -comobject wscript.shell
	$intAnswer = $PromptWindow.popup("File exists, do you want to overwrite?", 0, "Confirm", 4)
	#Button?Types
	#Value??Description
	#0?Show?OK?button.
	#1?Show?OK?and?Cancel?buttons.
	#2?Show?Abort,?Retry,?and?Ignore?buttons.
	#3?Show?Yes,?No,?and?Cancel?buttons.
	#4?Show?Yes?and?No?buttons.
	#5?Show?Retry?and?Cancel?buttons.
	if ($intAnswer -eq 7) {break}
}

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root

$search.Filter = "(&(objectclass=user)(objectcategory=person)(samAccountName=$Alias))"
$result = $search.FindOne()

if ($result.count -eq 1) {
	$user = $result.GetDirectoryEntry()
	$user.get("thumbnailphoto") | Set-Content $Photo -Encoding byte
	Write-Host ((EventTime) + "Picture downloaded from " + $user.displayname + ".") -ForegroundColor Green
}
else {
	Write-Host ((EventTime) + $Alias + "does not exist.") -ForegroundColor Red
}