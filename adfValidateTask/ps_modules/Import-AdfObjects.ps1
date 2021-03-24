function Import-AdfObjects {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)] $Adf,
        [parameter(Mandatory = $true)] $All,
        [parameter(Mandatory = $true)] [String] $RootFolder,
        [parameter(Mandatory = $true)] [String] $SubFolder
    )

    Write-Verbose "Analyzing $SubFolder dependencies..."

    $folder = Join-Path $RootFolder "$SubFolder"
    if (-Not (Test-Path -Path "$folder" -ErrorAction Ignore))
    {
        Write-Verbose "Folder: '$folder' does not exist. No objects to be imported."
        return
    }

    Write-Verbose "Folder: $folder"
    $jsonFiles = Get-ChildItem "$folder" -Filter "*.json" | Where-Object { !$_.Name.StartsWith('~') };
    foreach($item in $jsonFiles) {
        Write-Verbose "- $($item.Name)"
        $txt = Get-Content $item.FullName -Encoding "UTF8"
        $o = New-Object -TypeName AdfObject 
        $o.Name = $item.BaseName
        $o.Type = $SubFolder
        $o.FileName = $item.FullName
        
        try {
           $o.Body = $txt | ConvertFrom-Json
        }
        catch{
           throw ("Invalid json file: {0} `r`n{1}" -f $item.FullName, $_.Exception.Message)
        }

        $m = [regex]::matches($txt,'"referenceName":\s*?"(?<r>.+?)",[\n\r\s]+"type":\s*?"(?<t>.+?)"')
        $m | ForEach-Object {
            $o.AddDependant( $_.Groups['r'].Value, $_.Groups['t'].Value ) | Out-Null
        }
        $Adf.AllObjectName.Add($o.Name)
        $o.Adf = $Adf
        $All.Add($o)
        Write-Verbose ("- {0} : found {1} dependencies." -f $item.BaseName, $o.DependsOn.Count)
    }

}