$inputFile = "Q4\InputFile.txt" 
$search = "SEARCH"                    
$replace = "REPLACE"                  

if (-not (Test-Path $inputFile)) {
    Write-Host "Input file missing"
    exit 1
}

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
$outputFile = "$baseName.new"

(Get-Content -Path $inputFile) -replace $search, $replace | Set-Content -Path $outputFile
Write-Host "Output file ready- '$outputFile'."
