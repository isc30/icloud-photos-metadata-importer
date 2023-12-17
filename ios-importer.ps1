param (
    [Parameter(Mandatory)]
    [string]
    $PhotosPath
)

[System.Reflection.Assembly]::LoadFrom((Resolve-Path "TagLibSharp.dll"))

New-Item -ItemType Directory -Path (Join-Path -Path $PhotosPath "favorites")

Get-ChildItem $PhotosPath\*.csv | Foreach-Object {
    $CsvFilePath = Join-Path -Path $PhotosPath -ChildPath $_.Name
    $CsvFile = Import-Csv -Path $CsvFilePath -ErrorAction Stop
    foreach ($Row in $CsvFile) {
        $imgName = $Row.imgName
        $favorite = $Row.favorite
        $originalCreationDate = Get-Date $Row.originalCreationDate

        $imgFile = Resolve-Path (Join-Path -Path $PhotosPath -ChildPath $imgName)
        $file = Get-Item $imgFile
        $file.CreationTime = $originalCreationDate

        try {
            $tag = [TagLib.File]::Create($imgFile)
            if ($tag.ImageTag) {
                $tag.ImageTag.DateTime = $originalCreationDate
                if ($favorite -eq "yes") {
                    $tag.ImageTag.Keywords = ("favorite")
                }
            }

            if ($tag.Tag) {
                $tag.Tag.DateTime = $originalCreationDate
                if ($favorite -eq "yes") {
                    $tag.Tag.Keywords = ("favorite")
                }
            }

            $tag.Save()
        } catch {}

        if ($favorite -eq "yes") {
            Move-Item $imgFile -Destination (Join-Path -Path $PhotosPath "favorites" $imgName)
        }

        Write-Host $imgName - $originalCreationDate
    }
}
