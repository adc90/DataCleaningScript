function Invoke-JQuery
{
    [cmdletbinding()]
    param(
        [parameter(position=0, mandatory=$true)]
        $IE,
		
        [parameter(position=1,mandatory=$false)]
        $Command,
		
        [parameter()]
        $Function,
        
        [parameter()]
        [switch]$Initialize
    )
	if ($Initialize -or $Function){
		$url='http://code.jquery.com/jquery-1.4.2.min.js'
		$document = $IE.document 
		$head = @($document.getElementsByTagName("head"))[0] 
		$script = $document.createElement('script') 
		$script.type = 'text/javascript'
	}
    
	if ($Initialize){
		$script.src = $url 
		$head.appendChild($script) | Out-Null
	}

	if ($Command){
		$IE.document.parentWindow.execScript("$Command","javascript")
	}

	if ($Function){
		$script.text = $Function
		$head.appendChild($script) | Out-Null
	}
}
$jqueryExtraction = 
@"
	var x = jQuery('tr:not(:first)').map(function(i,v){ 
	   var test = jQuery.trim(jQuery(jQuery(v).children('td')[1]).text());
	   if(test !== '') {
		  return test;
	   }
	});
	var a = "";
	var t = function() {
		for(var i = 0; i < x.length; i++) {
			if(i !== 0) {
				a += ":" + x[i];
			} else {
				a += x[i];
			}
		}
	};
	t();
	jQuery('body').html(a);
"@

[System.Collections.ArrayList] $firstNames = [System.Collections.ArrayList]::new()
[System.Collections.ArrayList] $lastNames = [System.Collections.ArrayList]::new()
$request = Invoke-WebRequest "http://deron.meranda.us/data/census-dist-female-first.txt" 
$tmp = $request.ToString() -replace '(^\s+|\s+$)',' '  -replace '\s+',' ' -split ' ' | where { $_ -notmatch '^\d+$' } | where { $_ -notmatch '^\d+\.\d+$'} 
$firstNames.AddRange($tmp -split ' ')

$ie = new-object -com internetexplorer.application
$ie.visible = $true
$ie.navigate2("http://www.infoplease.com/ipa/A0778413.html")
while($ie.busy) {start-sleep 1}
Invoke-JQuery $ie $jqueryExtraction -Initialize

$lstNm = $ie.Document.body.innerHTML -split ':' | where { $_ -ne 'Miscellaneous' }
$lastNames.AddRange($lstNm)

Class PersonName
{
	$firstName = ""
	$lastName = ""
	$dateOfBirth = ""
	$address = ""
	$socialSecurityNumber = ""

	PersonName($fName, $lName, $dob, $ssn, $address) {
		$this.firstName = $fName
		$this.lastName = $lName
		$this.dateOfBirth = $dob
		$this.address = $address
		$this.socialSecurityNumber = $ssn
	}
}

function GenerateSSN {
	$g = 
	{
		return Get-Random -Minimum 0 -Maximum 9
	}

	"{0}{1}{2}-{3}{4}-{5}{6}{7}{8}" -f (&$g), (&$g), (&$g), (&$g), (&$g), (&$g), (&$g), (&$g), (&$g)
}

function RandomStreetName {
	$streetNames = @("Second", "Third", "First", "Fourth", "Park", "Fifth", "Main", "Sixth", "Oak", "Seventh", "Pine", "Maple", "Cedar", "Eighth", "Elm", "View", "Washington", "Ninth", "Lake", "Hill")
	$streetSuffix = @("St.", "Dr.", "Rd.")
	$streetPrefix = @("East", "West", "North", "South")

	$streetNm = { 
		$streetNames[(Get-Random -Minimum 0 -Maximum $streetNames.Count)] + " " 
	}
	$streetPre = { 
		if((Get-Random -Minimum 0.0 -Maximum 1.0) -lt 0.10) { 
			" " + $streetPrefix[(Get-Random -Minimum 0 -Maximum $streetPrefix.Count)] + " " 
		} else { 
			" " 
		} 
	}
	$streetSfx = { 
		$streetSuffix[(Get-Random -Minimum 0 -Maximum $streetSuffix.Count)] 
	}
	$stNum = (Get-Random -Minimum 1 -Maximum 10000).ToString()

	"{0}{1}{2}{3}" -f $stNum, (&$streetPre), (&$streetNm), (&$streetSfx)
}

function RandomDate {
	[DateTime]$minDate = "01/01/45"
	[DateTime]$maxDate = [DateTime]::Now

	$r = [Random]::new()
	$rTicks = [Convert]::ToInt64( ($maxDate.Ticks * 1.0 - $minDate.Ticks * 1.0 ) * $r.NextDouble() + $minDate.Ticks * 1.0 )
	$strFmt = if(Get-Random -Minimum 0 -Maximum 2 -eq 1) { "dd/MM/yyyy" } else { "dd/MM/yy" }

	[DateTime]::new($rTicks)
}

[System.Collections.ArrayList] $people = [System.Collections.ArrayList]::new()

$dataLoop = 10000

for ($i=1; $i -le $dataLoop; $i++)
{
	$fName = $firstNames.Item((Get-Random -Minimum 0 -Maximum $firstNames.Count))
	$lName = $lastNames.Item((Get-Random -Minimum 0 -Maximum $lastNames.Count))
	$dt = RandomDate
	$ssn = GenerateSSN
	$st = RandomStreetName
	$personTmp = [PersonName]::new($fName, $lName, $dt, $ssn, $st)

	$people.Add($personTmp)
}


$people | ConvertTo-Csv | Out-File ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)) + "\data.txt"


#| FirstName | LastName | DateOfBirth | SSN | Address | 
