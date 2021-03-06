<#
.SYNOPSIS
Validates files of ADF in a given location, returning warnings or errors.

.DESCRIPTION
Validates files of ADF in a given location. The following validation will be perform:
- Reads all files and validates its json format
- Checks whether all dependant objects exist
- Checks whether file name equals object name

.PARAMETER RootFolder
Source folder where all ADF objects are kept. The folder should contain subfolders like pipeline, linkedservice, etc.

.EXAMPLE
Validate-AdfCode -RootFolder "$RootFolder"

#>
function Test-AdfCode {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)] 
        [String] $RootFolder
    )

    $ErrorCount = 0
    $WarningCount = 0
    $adfName = Split-Path -Path "$RootFolder" -Leaf

    Write-Host "=== Loading files from location: $RootFolder ..."
    $adf = Import-AdfFromFolder -FactoryName "$adfName" -RootFolder "$RootFolder" -ErrorAction "SilentlyContinue"
    $AllObjects = $adf.AllObjects()
    $ObjectsCount = $AllObjects.Count

    Write-Host "=== Validating files ..."

    if ($ObjectsCount -eq 0) {
        $WarningCount += 1
        Write-Warning "No Azure Data Factory files have been found in a given location."
    }

    $idx=0;
    foreach($_ in $AllObjects){
        $idx++
        $FullName = $_.FullName($true)
        Write-Host "$idx`tChecking: $FullName..."
        $HasBody = $null -ne $_.Body
        if (-not $HasBody) {
            $ErrorCount += 1
            Write-Error -Message "Object $FullName was not loaded properly."
        }
        if ($HasBody) {

            if ($_.name -ne $_.Body.name) {
                $ErrorCount += 1
                Write-Error -Message "Object $FullName has mismatch file name."
            }

            $_.DependsOn | ForEach-Object {
                Write-Host "`t- Checking dependency: [$_]"
                if (!$adf.AllObjectName.Contains($_)) {
                    $ErrorCount += 1
                    Write-Error -Message "Couldn't find referenced object $_."
                }
            }
        }
    }

    $msg = "Validate code completed ($ObjectsCount objects)."
    $isError =$ErrorCount -gt 0
    if ($isError) { $msg = "Validate code failed." }
    $line1 = $adf.Name.PadRight(63) + "  # of Errors: $ErrorCount".PadLeft(28)
    $line2 = $msg.PadRight(63)      + "# of Warnings: $WarningCount".PadLeft(28)

    Write-Host "============================================================================================="
    Write-Host " $line1"
    Write-Host " $line2"
    Write-Host "============================================================================================="
}