#
# DataCleaner.ps1
#

#=============================
# Scrubbers
#=============================

function RemoveExtraSpaces ($line) {
	Write-Host "Testtt"
	return ($line -replace '\s+',' ').Trim()
}

function UppercaseWord ($line) {
	return $line.substring(0,1).toupper() + $line.substring(1).tolower()
}

function RemoveNumericCharacters($line) {
	$pattern = '[^a-zA-z]'
	return $line.Replace($pattern,'')
}

function RemoveNonNumericCharacters($line) {
	$pattern = '[a-zA-z]'
	return $line.Replace($pattern,'')
}
#=============================


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

function GetScrubbersMenu {
	$scrubbers = New-Object System.Collections.Specialized.OrderedDictionary
	$scrubbers.Add("0: Remove Numeric chars", "Function:RemoveNumericCharacters")
	$scrubbers.Add("1: Remove extra spaces", "Function:RemoveExtraSpaces")
	$scrubbers.Add("2: Uppercase Word", "Function:UppercaseWord")
	$scrubbers.Add("3: Remove Non-numeric chars", "Function:RemoveNonNumericCharacters" )

	return $scrubbers
}

function GetScrubbers {
	$arry = @()
	for() {
		$input = Read-Host
		if($input -eq "end") {
			break
		} else { 
			$arry += $input
		}
	}	
	return $arry
}

function GetScrubberFuncs($values, $menu) {
	$keys = [string[]] $menu.Keys

	$a = @()

	foreach($i in $values) {
		$key = $keys[$i] 
		$a += $menu[$key]
	}
	return $a
}


#=============================
# Process File
#=============================

function CleanLine($line, $cleanFuncs) {
	$line = $line.Split(",")
	#Write-Host $line
	Write-Host &($cleanFuncs[0]) "A     aa"
	#foreach($s in $line) {
	#	
	#}
}

function ProcessFile ($directory) {
	if(-Not (Test-Path $directory)) {
		throw [System.IO.FileNotFoundException]	 "$directory not found"
	} else {
		#Avoid using Get-Content since it's a little slower on large files
		$reader = [System.IO.File]::OpenText($directory)
		$dir = GetPathFromFile($directory)
		$dir = "$dir\cleanedData2.txt"
		if(Test-Path $dir) {
			Remove-Item $dir
		}	
		$writer = [System.IO.File]::AppendText($dir)
		$header = GetHeader
		
		$scrubbers = @{}		
		$scrubbersDict = GetScrubbersMenu

		Write-Host "Select a filter by number, type end to move to the next item"
		$scrubber = GetScrubbersMenu
		$keys = [string[]] $scrubber.Keys
		$keys | foreach { Write-Host $_ }

		foreach($itm in $header) {
			Write-Heading "Get scrubbers for column: $itm"
			$sbr = GetScrubbers
			$scrubbers.Add($itm, $sbr)
		}

		$processingStack = @{}
		foreach($itm in $scrubbers) {
			$values = $itm.Values
			$funcs = GetScrubberFuncs $values $scrubbersDict
			Write-Host $itm
			$processingStack.Add($itm, $functs)
		}

		$processingStack.Values | foreach { Write-Host $_ }

		try {
			$txt = ""
			for() {
				$line = $reader.ReadLine()
				if($line -eq $null) {
					break
				} else {
					CleanLine $line $processingStack
					#$writer.WriteLine($line)
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
