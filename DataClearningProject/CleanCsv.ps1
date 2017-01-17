#
# CleanCsv.ps1
#

function RemoveExtraSpaces ($line) {
	try {
		return ($line -replace '\s+',' ').Trim()
	} catch {
		return $line
	}
}

function RemoveSpaces ($line) {
	try {
		return ($line -replace '\s+',' ').Trim()
	} catch {
		return $line
	}
}

function UppercaseWord ($line) {
	try {
		return $line.substring(0,1).toupper() + $line.substring(1).tolower()
	} catch {
		return $line
	}
}

function RemoveNonAlphaCharacters($line) {
	try {
		return $line -replace '[^a-zA-z]' , ''
	} catch {
		return $line
	}
}

function RemoveNonNumericCharacters($line) {
	try {
		return $line -replace '[^0-9]' , ''
	} catch {
		return $line
	}
}

$dataFile = "C:\Users\adc90\Desktop\data1.txt"

$FirstName = @()
$LastName = @()
$BirthDate = @()
$StreetName = @()
$SocialSecurityNumber = @()

Import-Csv $dataFile |`
	ForEach-Object {
		$FirstName += UppercaseWord(RemoveSpaces($_.FirstName))
		$LastName += RemoveSpaces($_.LastName)
		$BirthDate += $_.BirthDate
		$StreetName += $_.StreetName
		$SocialSecurityNumber += RemoveNonNumericCharacters($_.SocialSecurityNumber)
	}

$rng = ($FirstName.Count -1)

0..$rng | % {
	[string]::Format("{0}, {1}, {2}, {3}, {4}", `
		$FirstName[$_], `
		$LastName[$_], `
		$BirthDate[$_], `
		$StreetName[$_], `
		$SocialSecurityNumber[$_]) `
	>> "C:\Users\adc90\Desktop\cleaned.txt"
}

