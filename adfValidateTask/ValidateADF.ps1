[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # import required modules
    Write-Output "PowerShell: $($PSVersionTable.PSVersion) $($PSVersionTable.PSEdition)"

    Import-Module -Name "$PSScriptRoot\init.psd1"

    # Get inputs params
    [string]$RootFolder = Get-VstsInput -Name "DataFactoryRoot" -Require;
    [string]$ContinueOnError = Get-VstsInput -Name "ContinueOnError" -AsBool;

    # [string]$RootFolder = "D:\Source\AdsTargetingADF\TargetingDataFactory";
    
    # $global:ErrorActionPreference = 'Stop';
    $global:ErrorActionPreference = if($ContinueOnError -eq $true) {'Continue'} else {'Stop'};

    Write-Host "Invoking Validate-AdfCode with the following parameters:";
    Write-Host "RootFolder:         $RootFolder";

    $null = Test-AdfCode -RootFolder "$RootFolder" 

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

