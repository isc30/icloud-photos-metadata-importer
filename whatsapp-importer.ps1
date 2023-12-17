param (
    [Parameter(Mandatory)]
    [string]
    $PhotosPath
)

Get-ChildItem $PhotosPath | Foreach-Object {
    $_.CreationTime = $_.LastWriteTime

    if ($_.BaseName -match ".*-(\d\d\d\d)(\d\d)(\d\d)-.*") {
        $date = [DateTime]"$($matches[1])-$($matches[2])-$($matches[3])"
        $_.CreationTime = $date
    }
    
    $check = ""
    for ($i=1; $i -le 30; $i++) {
        $check += "_$i"
        if ($_.BaseName -match "$check$") {
            if (Test-Path $_.FullName.Replace($_.BaseName, $_.BaseName.Substring(0,$_.BaseName.Length-$check.Length))) {
                Write-Host "Deleted $($_.FullName)"
                Remove-Item $_.FullName
            }
        }
    }
}
