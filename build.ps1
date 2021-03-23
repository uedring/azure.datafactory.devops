[CmdletBinding()]
param
(
    [int]     [Parameter(Mandatory = $true)] $build = 0
)

$now = (Get-Date).ToUniversalTime()
$ts = New-TimeSpan -Hours $now.Hour -Minutes $now.Minute
$versionPatch = $ts.TotalMinutes
if ($build -gt 0) { $versionPatch = $build }

# Update extension's manifest
$vssFile = Join-Path -Path (Get-Location) -ChildPath 'vss-extension.json'
$body = Get-Content $vssFile -Raw
$JsonDoc = $body | ConvertFrom-Json
$ver = $JsonDoc.Version
$verarr = $ver.Split('.')
$ver = "{0}.{1}.{2}" -f $verarr[0], $verarr[1], $versionPatch
$verarr[2] = $versionPatch
Write-Output "Module version: $ver"

#replace with regex
$v = '"version": "'+$JsonDoc.Version+'",'
$nv = '"version": "'+$ver+'",'

$body = $body.Replace($v, $nv)
#$JsonDoc.version = $ver
#$JsonDoc | ConvertTo-Json | Out-File "$vssFile" -Encoding utf8
$body  | Out-File "$vssFile" -Encoding utf8
Write-Output "File vss updated."

# Update task's manifest
$taskFile = Join-Path -Path (Get-Location) -ChildPath 'adfValidateTask\task.json'
#Copy-Item -Path $taskFile -Destination "$taskFile - copy"
Write-Output "Updating version for task definition in file: $taskFile"
$body = $JsonDoc = Get-Content $taskFile -Raw
$JsonDoc = $body | ConvertFrom-Json
#$JsonDoc.version.Major = $verarr[0]
#$JsonDoc.version.Minor = $verarr[1]
#$JsonDoc.version.Patch = $versionPatch  #$verarr[2]
$body = $body.Replace('"Major": '+$JsonDoc.version.Major, '"Major": '+$verarr[0])
$body = $body.Replace('"Minor": '+$JsonDoc.version.Minor, '"Minor": '+$verarr[1])
$body = $body.Replace('"Patch": '+$JsonDoc.version.Patch, '"Patch": '+$versionPatch)

#$JsonDoc | ConvertTo-Json | Out-File "$taskFile" -Encoding utf8
$body | Out-File "$taskFile" -Encoding utf8
Write-Output "File task #1 updated."

tfx extension create --manifest-globs vss-extension.json --output-path ./bin



