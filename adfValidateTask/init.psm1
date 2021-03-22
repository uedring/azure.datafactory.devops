$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest


if ($true -and ($PSEdition -eq 'Desktop'))
{
    if ($PSVersionTable.PSVersion -lt [Version]'5.1')
    {
        throw "PowerShell versions lower than 5.1 are not supported in Az. Please upgrade to PowerShell 5.1 or higher."
    }
}

if (Test-Path -Path "$PSScriptRoot\ps_modules" -ErrorAction Ignore)
{
    Get-ChildItem "$PSScriptRoot\ps_modules" -ErrorAction Stop | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object {
        Write-Host "Importing cmdlet '$($_.Name)'."
        . $_.FullName
    }
}