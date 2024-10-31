$start_time = Get-Date
# Verzeichnis der Workshopinhalte
$mods_dir = "C:\Program Files (x86)\Steam\steamapps\workshop\content\221100"

# Mapping der Workshop IDs zu den Ordnernamen auf dem Server
$csv = Import-Csv -Path ".\ressources\modmapping.csv" -Delimiter ";" 
# Minimales alter der Änderungen
$age = -1

Write-Host "Checking Mod updates at" $start_time
Write-Host "Searching for Mods updated in the last" ($age * -1) "days"
Write-Host "-----------------"
Write-Host ""

# Erstelle eine Lookup Table fuer die Workshop-Ids
$lookupHash = @{}
$csv.foreach({ $lookupHash[$psitem.mod_id.tolower()] = $psitem.name_server })
Get-ChildItem $mods_dir -Directory | ForEach-Object {
  # Loope durch die Unterordner um Files zu finden die in den letzten x Tagen geändert wurden
  $mod_files = Get-ChildItem $_.FullName -File -Recurse | 
  Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays($age) }

  $updated_mods = $mod_files | Get-ChildItem -Directory | Select-Object -Property Directory,LastWriteTime | Get-Unique 

  :innerloop foreach ($object in $updated_mods) {
    [string[]]$dir_str = $_
    # Finde die Workshop ID
    $steam_id = [regex]::Match($dir_str, '\d{10}').Value
    # Finde den korrespondierenden Ordnernamen auf dem Server
    $server_dir_name = $lookupHash[$steam_id]

    $last_wt = $_ | Select-Object LastWriteTime | Get-Unique | Get-Date
    if ([string]::IsNullOrEmpty($server_dir_name)) {
      continue innerloop
    }
    Write-Host "Updated Mod: Workshop-ID" $steam_id "; Server Folder Name:" $server_dir_name "at" $last_wt
  }


}

$finish_time = Get-Date
Write-Host ""
Write-Host "--------------"
Write-Host "Process finished at" $finish_time