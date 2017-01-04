#
# DataCleaner.ps1
#

#=============================
# Scrubbers
#=============================
function RemoveExtraSpaces ($line) {
	return ($line -replace '\s+',' ').Trim()
}

function RemoveSpaces ($line) {
	return ($line -replace '\s+','').Trim()
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
	$scrubbers.Add("0: Remove Numeric chars", (gi function:RemoveNumericCharacters))
	$scrubbers.Add("1: Remove extra spaces", (gi function:RemoveExtraSpaces))
	$scrubbers.Add("2: Uppercase Word", (gi function:UppercaseWord))
	$scrubbers.Add("3: Remove Non-numeric chars", (gi function:RemoveNonNumericCharacters ))
	$scrubbers.Add("4: Remove all spaces", (gi function:RemoveSpaces ))

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
	$values | foreach { $a += $menu[$keys[$_]] }
	return $a
}


#=============================
# Process File
#=============================

function CleanLine($lines, $cleanFuncs) {
	$line = $lines.toString().Split(",")
	$i = 0
	$cleanedLine = @()
	$line | foreach {
		$itm = $_
		if($cleanFuncs.ContainsKey($i))	{
			try {
				$cleanFuncs[$i] | foreach {
					$itm = (& $_($itm))
					$a = "A"
				}
			} catch {
				$t = $_
			}
		}
		$i++
		$cleanedLine += $itm
	}

	return $cleanedLine.Join(",")

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
		$i = 0
		foreach($itm in $scrubbers) {
			$values = $itm.Values
			$funcs = GetScrubberFuncs $values $scrubbersDict
			$processingStack.Add($i, $funcs)
			$i++
		}

		try {
			$txt = ""
			for() {
				$line = $reader.ReadLine()
				if($line -eq $null) {
					break
				} else {
					$line = CleanLine $line $processingStack
					$writer.WriteLine($line)
				}
			}
		} finally {
			$writer.Close()
			$reader.Close()
		}

	}
}

#Write-Heading "Data cleaning utility"
#$dataFile = SetDirectory "Set in input file" "Please enter a valid file"
$dataFile = "C:\Users\adc90\Desktop\data.txt"
ProcessFile $dataFile

#$t = @{}
#$t.Add("a", (gi function:RemoveExtraSpaces))
#Write-Host (& $t["a"]("A         b"))
#UppercaseWord
#RemoveNumericCharacters
#RemoveNonNumericCharacters
