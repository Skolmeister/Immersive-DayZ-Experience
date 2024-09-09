
# Definiere Quell- und Zielordner
$server_dir = "C:\Users\alexa\projects\Immersive-DayZ-Experience\server-files"
$ftp_dir =  "C:\Users\alexa\projects\test"
# Minimales alter der Änderungen
$age = -120
# Ziehe alle Unterordner aus dem Quellordner
Get-ChildItem $server_dir -Directory | ForEach-Object {
  # Loope durch die Unterordner um Files zu finden die in den letzten x Minuten geändert wurden
  $mod_files = Get-ChildItem $_.FullName -File -Recurse | 
    Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes($age)}

  # Gehe durch die gefundenen Files und schaue wohin diese verschoben werden müssen
  $mod_files |
    ForEach-Object {
      $dir = $_ | Select-Object Directory
      # Generiere den Zielordner-Pfad auf dem FTP Server 
      switch -regex ($dir) {
        '\\server-files\\config' {
          [string[]]$dir_str=$dir.Directory 
          $detailed_dir = [regex]::Match($dir_str, '(?<=\\server-files\\config).*').Value
          $path_output = $ftp_dir + '\config' + $detailed_dir
        }
        '\\server-files\\mpmissions' {
          [string[]]$dir_str=$dir.Directory 
          $detailed_dir = [regex]::Match($dir_str, '(?<=\\server-files\\mpmissions).*').Value
          $path_output = $ftp_dir + '\mpmissions' + $detailed_dir
        }
      }
      # Wenn der Zielordner nicht existiert wird dieser erstellt
      If(!(Test-Path -PathType Container $path_output)) {
        [void](New-Item -ItemType Directory -Path $path_output)
      }
      # Kopiere jedes Item an die richtige Stelle
      $_ | Copy-Item -Force -Destination $path_output
    }
}

