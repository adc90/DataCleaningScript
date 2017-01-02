#
# DataCleaner.ps1
#

function Write-Heading ($item)
{
	$header = "-------------------------"
	Write-Host "$header`n$item`n$header"
}

function SetDirectory ($initialMessage, $errorMessage) {
	Write-Host $initialMessage
	$inputPath = Read-Host
	while(-Not(Test-Path $inputPath))
	{
		Write-Host $errorMessage
		$inputPath = Read-Host
	}

	return $inputPath
}

function GetPathFromFile ($dataFile) {
	$fileName = [string]$dataFile.Split("\")[$path.Count - 1]
	return $dataFile.Replace("\$fileName", "")
}

function GetHeader {
	Write-Host "Enter in the files header Terminate by typing end"
	$header = @()
	for() {
		$input = Read-Host
		if($input -eq "end") {
			break
		} else { 
			$header += $input
		}
	}
	return $header
}

function RemoveExtraSpaces ($line) {
	return ($line -replace '\s+',' ').Trim()
}

function UppercaseWord ($line) {

}

function ProcessFile ($directory) {
	if(-Not (Test-Path $directory)) {
		throw [System.IO.FileNotFoundException]	 "$directory not found"
	} else {
		#Avoid using Get-Content since it's a little slower on large files
		$reader = [System.IO.File]::OpenText($directory)
		$dir = GetPathFromFile($directory)
		$dir = "$dir\cleanedData.txt"
		$writer = [System.IO.File]::AppendText($dir)
		$header = GetHeader
		$a = ConvertFrom-Csv $directory -Header $header
		Write-Host $a
		try {
			$txt = ""
			for() {
				$line = $reader.ReadLine()
				if($line -eq $null) {
					break
				} else {
					$line = RemoveExtraSpaces($line)
					$writer.WriteLine($line)
				}
			}
		} finally {
			$writer.Close()
			$reader.Close()
		}

	}
}

Write-Heading "Data cleaning utility"
$dataFile = SetDirectory "Set in input file" "Please enter a valid file"
ProcessFile $dataFile
