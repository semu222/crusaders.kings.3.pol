$comOrg = $true;

$projDir = "H:\Projects\crusaders.kings.3.pol";

$loc = "$projDir\ck3.spolszczenie\localization";

$cats = '[ "spolszczenie.1.1.3", "spolszczenie.dodatki" ]' | ConvertFrom-Json;
$eng = "english.1.2.1";

$data = New-Object System.Collections.Hashtable;
foreach($cat in $cats) {
    $spDir = "$projDir\$cat\english";
    $files = Get-ChildItem -Path $spDir -File -Filter "*.yml" -Recurse;
    foreach($file in $files) {
        $path = $file.Directory.FullName.Substring($spDir.Length).TrimStart('\');
        $name = $file.Name;
    
        Write-Output "$cat $name /$path";

        $lines = Get-Content $file.FullName -Encoding UTF8;
        foreach($line in $lines) {
            if ($line.Trim() -eq '') {
                continue;
            }
            if ($line.Trim().StartsWith("#")) {
                continue;
            }
            if (!$line.StartsWith(" ")) {
                continue;
            }
            $line = $line.Trim();
            $x = $line.IndexOf(" ");
            if ($x -lt 0) {
                continue;
            }
            $code = $line.Substring(0, $x);
            $value = $line.Substring($x + 1);
            if ($data.ContainsKey($code)) {
                $pos = $data[$code];            
            } else {
                $pos = @();
            }
            $pos += $value;
            $data[$code] = $pos;
        }
    
    }

}

if (Test-Path $loc) {
    $ri = Remove-Item -Path $loc -Recurse -Force;
}
$ni = New-Item -Path $loc -ItemType Directory;

$engDir = "$projDir\$eng\english";
$files = Get-ChildItem -Path $engDir -File -Filter "*.yml" -Recurse;
foreach($file in $files) {
    $path = $file.Directory.FullName.Substring($engDir.Length).TrimStart('\');
    $name = $file.Name;
    
    Write-Output "$eng $name /$path";
    $lines2 = @();
    $lines = Get-Content $file.FullName -Encoding UTF8;
    foreach($line in $lines) {
        if ($line.Trim() -eq '') {
            $lines2 += $line;
            continue;
        }
        if ($line.Trim().StartsWith("#")) {
            $lines2 += $line;
            continue;
        }
        if (!$line.StartsWith(" ")) {
            $lines2 += $line;
            continue;
        }
        $line = $line.Trim();
        $x = $line.IndexOf(" ");
        if ($x -lt 0) {
            $lines2 += $line;
            continue;
        }
        $code = $line.Substring(0, $x);
        $value = $line.Substring($x + 1);

        if ($data.ContainsKey($code)) {
            $pos = $data[$code];
            $nvalue = $null;
            foreach($item in $pos) {
                if ($value -cne $item) {
                    $nvalue = $item;
                }
            }
            if ($nvalue) {
                if ($comOrg) {
                    $lines2 += "#$code $value";
                }
                $value = $nvalue;
            }
        }
        $lines2 += " $code $value";
    }
    $outPath = "$projDir\ck3.spolszczenie\localization\english\$path";
    if (!(Test-Path $outPath)) {
        $ni = New-Item -Path "$outPath" -ItemType Directory;
    }
    Set-Content "$outPath\$name" $lines2 -Encoding UTF8;
}
