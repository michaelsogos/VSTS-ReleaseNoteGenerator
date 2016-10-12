##-----------------------------------------------------------------------
## <copyright>(c) Michael Sogos</copyright>
##-----------------------------------------------------------------------
# Create a release note file in MarkDown format

[CmdletBinding()]
param (
    [parameter(Mandatory=$true,HelpMessage="Path to release note output file")] [string]$outputfile,
	[parameter(Mandatory=$true,HelpMessage="Activate logs")] [string]$showExtensionLogs
)

$showLogs = $false
if($($showExtensionLogs) -eq "true"){
	$showLogs = $true
}

#region "Presentation"
if($showLogs){
	Write-Host "====================================" -ForegroundColor Magenta
	Write-Host "| VSTS Build ReleaseNote Generator |" -ForegroundColor Magenta
	Write-Host "| - Version: 1.0.12                |" -ForegroundColor Magenta
	Write-Host "| - Author:  Michael Sogos         |" -ForegroundColor Magenta
	Write-Host "| - License: MIT                   |" -ForegroundColor Magenta
	Write-Host "====================================" -ForegroundColor Magenta
}
#endregion

#region "Variable Definition"
$buildId = $env:BUILD_BUILDID
$releaseId = $env:RELEASE_RELEASEID
$buildDefinitionName = $env:BUILD_DEFINITIONNAME 
$buildNumber = $env:BUILD_BUILDNUMBER 
$headers = @{Authorization=("Bearer {0}" -f $env:SYSTEM_ACCESSTOKEN)}
$urlChangeSets = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/build/builds/$($buildId)/changes?api-version=2"

if($showLogs){
	Write-Host "Build ID: $($buildId)" -ForegroundColor Yellow 
	Write-Host "Release ID: $($releaseId)" -ForegroundColor Yellow
	Write-Host "Credentials: Using agent default OAuth credentials" -ForegroundColor Yellow
	Write-Host "Output: $($outputfile)" -ForegroundColor Yellow
}
#endregion

#region "Get ChangeSets associated to build"
Write-Host "Retrieving changesets associated to build $($buildId)."
$changeSets = ""
Try{
    $changeSets = Invoke-RestMethod -Method Get -Uri $urlChangeSets -headers $headers -ErrorAction Stop
}
Catch{        
    Write-Error "REST API return [$($_.Exception.Message)] getting changesets associated to build with id $($buildId)!"
	Write-Error "REST API URL: $($urlChangeSets)"
    Exit 1    
}
if($changeSets.GetType().Name -ne "PSCustomObject"){
    Write-Error "REST API response is not an object, probably because the authentication failed!"
    Write-Error $changeSets Cyan
    Exit 1
}
#endregion

#region "Generate Markdown File for Release Note"
Write-Host "Generating markdown file ..."
$result = "# Release notes for build **$($buildDefinitionName)**  "
$result += "`r`n**Build Number** : $($buildNumber)  " 
$result += "`r`n"
$result += "## Associated changesets/commits`r`n"
$result += Foreach ($changeSet in $changeSets.value){
	Write-Output "`r`n#### $("{0:dd/MM/yy HH:mm:ss}" -f [datetime]$changeSet.timestamp) - _@$($changeSet.author.displayName)_  " 
	Write-Output "`r`n$($changeSet.message)  "
	Write-Output "`r`n"
    if($showLogs) { 
		Write-Host "ChangeSet Comment: $($changeSet)" -ForegroundColor Yellow
	}
} 

$result | Out-File $outputfile

Write-Host "$($outputfile) file has been generated!" 
#endregion