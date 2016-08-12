##-----------------------------------------------------------------------
## <copyright>(c) Michael Sogos</copyright>
##-----------------------------------------------------------------------
# Create a release note file in MarkDown format

[CmdletBinding()]
param (
    [parameter(Mandatory=$true,HelpMessage="Path to release note output file")] $outputfile
)


#region "Presentation"
Write-Verbose "===================================="
Write-Verbose "| VSTS Build ReleaseNote Generator |"
Write-Verbose "| - Version: 1.0.3                 |"
Write-Verbose "| - Author:  Michael Sogos         |"
Write-Verbose "| - License: MIT                   |"
Write-Verbose "===================================="
#endregion

#region "Variable Definition"
$buildId = $env:BUILD_BUILDID
$releaseId = $env:RELEASE_RELEASEID
$buildDefinitionName = $env:BUILD_DEFINITIONNAME 
$buildNumber = $env:BUILD_BUILDNUMBER 

$headers = @{Authorization=("Bearer {0}" -f $env:SYSTEM_ACCESSTOKEN)}
$urlChangeSets = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)/DefaultCollection/$($env:SYSTEM_TEAMPROJECT)/_apis/build/builds/$($buildId)/changes?api-version=2"

Write-Verbose "Build ID: $($buildId)"
Write-Verbose "Release ID: $($releaseId)"
Write-Verbose "Credentials: Using agent default OAuth credentials"
Write-Verbose "Output: $($outputfile)"
#endregion

#region "Get ChangeSets associated to build"
Write-Host "Retrieving changesets associated to build $($buildId)." 
Write-Verbose "ChangeSets URL: $($urlChangeSets)"
$changeSets = ""
Try{
    $changeSets = Invoke-RestMethod -Method Get -Uri $urlChangeSets -headers $headers -ErrorAction Stop
}
Catch{        
    Write-Error "REST API return [$($_.Exception.Message)] getting changesets associated to build with id $($buildId)!"
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
} 

$result | Out-File $outputfile

Write-Host "$($outputfile) file has been generated!" 
#endregion