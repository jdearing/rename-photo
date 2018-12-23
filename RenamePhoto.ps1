# see https://til.secretgeek.net/powershell/rename_photos.html
# usage example:
# dir *.jpg | % { Rename-Photo $_.FullName "iPhoneLB" "Martinique" }

function rename-photo(
    [ValidateScript({Test-Path $_})][string]$fileName,
    [int]$AddHours){

	if ($fileName -eq "") {
		write-host "Please provide a filename!" -foregroundcolor "red"
		write-host 'Full example: dir *.jpg | % { Rename-Photo $_.FullName "iPhoneLB" "Martinique" }'
		return;
	}

	if ((Test-Path $fileName) -eq $false) {
		write-host "File not found $fileName!" -foregroundcolor "red"
		write-host 'Full example: dir *.jpg | % { Rename-Photo $_.FullName "iPhoneLB" "Martinique" }'
		return;
	}

	$null = [reflection.assembly]::LoadWithPartialName("System.Drawing")
	$pic = New-Object System.Drawing.Bitmap($fileName)

	if ($pic) {
		# via http://stackoverflow.com/questions/6834259/how-can-i-get-programmatic-access-to-the-date-taken-field-of-an-image-or-video
		$bitearr = $pic.GetPropertyItem(36867).Value # Date Taken

		$pic.Dispose()
	}

	if ($bitearr -ne $null) {

		$string = [System.Text.Encoding]::ASCII.GetString($bitearr)
		$exactDate = [datetime]::ParseExact($string,"yyyy:MM:dd HH:mm:ss`0",$Null)

    } else {

		# we could not extract an EXIF "Date Taken".
		Get-ChildItem $fileName | ForEach-Object { $exactDate = $_.CreationTime; }
	}

	if ($AddHours -ne 0) {
		$exactDate = $exactDate.AddHours($AddHours)
	}

    $length = (Get-ChildItem $fileName | ForEach-Object length )
	$extensionWithDot = [io.path]::GetExtension($FileName)
	$newName = ("{0:yyyy-MM-dd-HH-mm-ss}-{1}{2}" -f $exactDate, $length, $extensionWithDot)

	write-host "Creating: $newName"
	rename-item $fileName $newName
}