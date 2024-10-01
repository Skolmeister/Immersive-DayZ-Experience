$start_time = Get-Date
# Verzeichnis der Workshopinhalte
$mods_dir = "C:\Program Files (x86)\Steam\steamapps\workshop\content\221100"
# Verzeichnis der Server Files
$server_dir =  "D:\SteamLibrary\steamapps\common\DayZServer"
# Mapping der Workshop IDs zu den Ordnernamen auf dem Server
$csv = Import-Csv -Path ".\ressources\modmapping.csv" -Delimiter ";" 
# Minimales alter der Änderungen
$age = -7

# Erstelle eine Lookup Table fuer die Workshop-Ids
$lookupHash = @{}
$csv.foreach({ $lookupHash[$psitem.mod_id.tolower()] = $psitem.name_server})

$greenCheck = @{
  Object = [Char]8730
  ForegroundColor = 'Green'
  NoNewLine = $true
  }

$redCross = @{
  Object = [Char]120
  ForegroundColor = 'Red'
  NoNewLine = $true
  }

Write-Host "--- Searching for Updated Mods --- "
Write-Host "Process started at" $start_time

Get-ChildItem $mods_dir -Directory | ForEach-Object {
  # Loope durch die Unterordner um Files zu finden die in den letzten x Tagen geändert wurden
  $mod_files = Get-ChildItem $_.FullName -File -Recurse | 
    Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays($age)}

  # Loope durch die gefundenen Files
  $mod_files |
  ForEach-Object {
    Write-Host '-------------------------'
    # Generiere String mit Ordnerpfad
    $dir = $_ | Select-Object Directory
    [string[]]$dir_str=$dir.Directory
    # Finde die Workshop ID
    $steam_id = [regex]::Match($dir_str, '\d{10}').Value
    # Finde den korrespondierenden Ordnernamen auf dem Server
    $server_dir_name = $lookupHash[$steam_id]
    Write-Host 'Found Updated File ' -NoNewline
    Write-Host $_ -NoNewLine -ForegroundColor Green 
    Write-Host ' in Mod ' -NoNewLine
    Write-Host $server_dir_name -ForegroundColor DarkCyan
    Write-Host 'Checking Timestamp of ' -NoNewline 
    Write-Host $_ -NoNewLine -ForegroundColor Green
    Write-Host ' on Server!'
    # Generiere den Pfad wohin das File kopiert werden soll (ersetze Workshop ID durch Ordnername auf dem Server und Basispfad durch Serverpfad)
    $path_new = $dir_str.Replace($steam_id, $server_dir_name).Replace($mods_dir, $server_dir)
    # Generiere den gesamten Pfad des Files und extrahiere es als Item
    $file_new = -join($path_new, "\", $_)
    $server_file = Get-Item $file_new

    # Vergleiche die LastWriteTimes von Workshop- und Serverfile
    if (($server_file.LastWriteTime) -lt ($_.LastWriteTime)) 
    {
      Write-Host @redCross
      Write-Host 'Server File is older than your workshop content!'
      Write-Host 'Updating Now!'
      Write-Host 'Copy from:' -NoNewline 
      Write-Host $dir_str -ForegroundColor DarkBlue
      Write-Host 'Copy to:' -NoNewLine
      Write-Host $path_new -ForegroundColor DarkBlue
      $_ | Copy-Item -Destination $path_new
      $server_file_updated = Get-Item $file_new
      if(($server_file_updated.LastWriteTime) -eq ($_.LastWriteTime)) {
        Write-Host @greenCheck
        Write-Host "Update successful, LastWriteTime matches between Workshop and Server File"
      } else {
        Write-Host @redCross
        Write-Host "LastWriteTime mismatch! Please check the file manually!"
      }

    } else {
      Write-Host @greenCheck 
      Write-Host ' Server File is already up to date!'
      Write-Host 'No need to update!'
    }

    Write-Host '-------------------------'
    # $_ | Copy-Item -Destination $path_new
  }

}

$finish_time = Get-Date
Write-Host "Process finished at" $finish_time