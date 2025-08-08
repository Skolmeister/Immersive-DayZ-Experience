
# 🐧 Debian 12: Einsteigerfreundliche Anleitung zur Installation & Einrichtung

## 💿 1. Debian 12 installieren

1. Wähle „Graphical Install“ oder „Install“.
2. Wähle Sprache, Region und Tastatur-Layout.
3. **Netzwerk einrichten**: Per DHCP oder manuell.
4. **Benutzerkonten**:
   - Setze ein **Root-Passwort**.
   - Erstelle einen **Standardbenutzer**.
5. **Partitionierung**:
   - „Geführt – gesamte Festplatte verwenden“ (für Anfänger empfohlen).
6. **Installation abschließen**:
   - Wähle ggf. weitere Pakete (z. B. SSH-Server).
   - Installiere den GRUB-Bootloader.
7. Nach Abschluss: Entferne den USB-Stick und starte neu.

---

## 🛠️ 2. System einrichten und sichern

### 🔐 Updates und SSH aktivieren
```bash
sudo apt update && sudo apt upgrade -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 🛡️ Firewall (UFW) installieren und aktivieren
```bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw enable
```

### 💾 Wichtige Pakete installieren
```bash
sudo apt install sudo curl vim git htop fail2ban -y
```

### 🔒 Sicherheitsmaßnahmen
- **Fail2Ban** schützt vor Brute-Force-Angriffen.
- UFW lässt nur Ports zu, die du freigegeben hast.

---

## 🐳 3. Docker installieren


### Schritt-für-Schritt:
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Zum testen ob alles läuft:

```bash
sudo docker run hello-world
```

### Benutzer zur Docker-Gruppe hinzufügen:

Zuerst eine Gruppe erstellen und dann den Nutzer hinzufügen

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

Dann **neu einloggen**, damit die Gruppenänderung aktiv wird.

Und einmal testen obs geht:

```bash
docker run hello-world
```

### Docker mit Start des Servers starten

Der Service muss einmal eingeschaltet werden.

``` bash
 sudo systemctl enable docker.service
 sudo systemctl enable containerd.service
```

---

## 👤 4. Weitere Benutzer anlegen und SSH-Zugang per Key einrichten

Ich würde mind. einen weiteren Nutzer (ohne `root` Privilegien) anlegen. Dieser sollte dann nur Zugriff auf die für DayZ relevanten Daten haben.
Der Nutzer kann z.B. `dayz` heißen und sollte dann auch für mich nutzbar sein (dafür das SSH)

### Benutzer anlegen:
Und für docker freigeben.
```bash
sudo adduser dayz
sudo usermod -aG docker $USER
```

### SSH-Verzeichnis und Berechtigungen setzen:
```bash
sudo mkdir -p /home/dayz/.ssh
sudo chown dayz:dayz /home/dayz/.ssh
sudo chmod 700 /home/dayz/.ssh
```

### Public Key hinzufügen:
1. Öffne die Datei:
   ```bash
   sudo vim /home/dayz/.ssh/authorized_keys
   ```
2. Füge den **Public SSH Key** des Benutzers ein (z. B. aus `id_rsa.pub`).
   1. Ich hab meinen Public Key selbst mitgebracht, den können wir dann einfach reinkopieren
3. Berechtigungen setzen:
   ```bash
   sudo chown dayz:dayz /home/dayz/.ssh/authorized_keys
   sudo chmod 600 /home/dayz/.ssh/authorized_keys
   ```

### SSH-Zugang nur mit Key erlauben:
```bash
sudo vim /etc/ssh/sshd_config
```

Folgende Werte ändern/ergänzen:
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Dann:
```bash
sudo systemctl restart ssh
```

---

## 5. DayZ-Server-Manager installieren

Erstmal hier der [Link zum Github Repo](https://github.com/mr-guard/dayz-server-manager?tab=readme-ov-file#configuration), dort steht alles wissenswerte auch nochmal.

## Installation

Zunächst auf den `dayz` User wechseln und ein Verzeichnis erstellen, in dem der Server dann nachher installiert wird. Da wir `docker` für den Server Manager nutzen, erstellen wir das Verzeichnis als Unterverzeichnis von `~/docker/`.
In dem Verzeichnis erstellen wir nun das `docker-compose.yml` File, von dem aus der Container gesteuert wird.


```bash
su dayz
# Passwort eingeben
mkdir docker/dayz
cd docker/dayz
vim docker-compose.yml
```

Folgenden Inhalt kopieren wir dann in den Editor und schließen mit `:wq`

```yaml
services:
  dayz:
    image: ghcr.io/mr-guard/dayz-server-manager:latest
    ports:
      - 2302-2312:2302-2312/udp
      - 2306:2306/tcp
      - 8766:8766/udp
      - 27016:27016/udp
      - 2080:8080/tcp # publish the web server on port 8080 in your config
    volumes:
      - /home/alex/docker/dayz:/dayz # make sure your server-manager.json is in there
    tty: true # needed for inputs
```

Wichtig ist, dass die korrekten Ports freigegeben werden. Die ersten vier Einträge unter `ports` sind tatsächlich für den Server benötigt, der letzte (hier `2080`, kann aber auch einfach `8080` sein)

Anschließend starten wir den Container mit `docker compose up -d` (das `-d` lässt den Container `detached`, also im Hintergrund starten). Die Logs können wir uns mit `docker compose logs` anschauen (dort sehen wir ob alles funktioniert)

Das ganze kann ein weilchen dauern und sollte uns Vanilla DayZ installieren und im aktuellen verzeichnis eine Datei names `server-config.json` erstellen.

Hier der Hinweis dazu von Github:

> Edit the server-manager.json config to fit your needs
> 
> Fill the required fields (everything is described in the file) 
> 
> !IMPORTANT! Change the admin and rcon password
> 
> Other than that the defaults will probably fit your needs
> 
> You can also checkout the configuration guides

Folgende Konfiguration habe ich auf meinem Server verwendet, um unseren Live-Server nachzubilden:

```json
{
  "instanceId": "dayz",
  "loglevel": 1,
  "admins": [
    {
      "userId": "admin",
      "userLevel": "admin",
      "password": "geheimespasswort"
    },
    {
      "userId": "skolmeister",
      "userLevel": "admin",
      "password": "geheimespasswort"
    }
  ],
  "webPort": 8080,
  "publishWebServer": true,
  "ingameApiPort": 0,
  "publishIngameApi": false,
  "ingameApiHostOverride": null,
  "ingameApiKey": "075694b3-d8e9-49cb-857a-3517ca5579f0",
  "syberiaCompat": false,
  "mapHost": {
    "fullImage": "https://github.com/Shawminator/DayZeEditor/blob/master/dayzlootmanager/Maps/ChernarusPlus_Map.png?raw=true",
    "worldSize": 15360
  },
  "discordBotToken": "UNSERTOKEN",
  "discordChannels": [
    {
      "channel": "bots-corner",
      "mode": [
        "notification"
      ]
    },
    {
      "channel": "dayz-server-admin",
      "mode": [
        "admin",
        "rcon"
      ]
    }
  ],
  "serverPath": "DayZServer",
  "serverExe": "DayZServer",
  "serverPort": 2302,
  "serverCfgPath": "serverDZ.cfg",
  "profilesPath": "profiles",
  "battleyePath": "",
  "rconPassword": "rconpasswort",
  "rconPort": 2306,
  "rconIP": "",
  "useRconToRestart": true,
  "localMods": [],
  "serverMods": [],
  "doLogs": true,
  "adminLog": true,
  "netLog": false,
  "freezeCheck": true,
  "filePatching": false,
  "scriptDebug": true,
  "scrAllowFileWrite": true,
  "limitFPS": -1,
  "cpuCount": -1,
  "dayzsettingpcmaxcores": 2,
  "dayzsettingreservedcores": 1,
  "dayzsettingglobalqueue": 4096,
  "dayzsettingthreadqueue": 1024,
  "serverLaunchParams": [],
  "serverProcessPollIntervall": 30000,
  "disableStuckCheck": false,
  "disableServerMonitoring": false,
  "lockServerRestart": false,
  "disableServerLockLogs": false,
  "experimentalServer": false,
  "dayzSteamAppId": "221100",
  "dayzServerSteamAppId": "223350",
  "dayzExperimentalServerSteamAppId": "1042420",
  "prerequisitesMandatory": true,
  "backupPath": "backups",
  "backupMaxAge": 7,
  "steamCmdPath": "SteamCMD",
  "steamUsername": "deinSteamUser",
  "steamPassword": "",
  "steamGuardCode": "",
  "steamWorkshopPath": "Workshop",
  "steamMetaPath": "SteamMeta",
  "steamWsMods": [
      "2579252958",
      "2912241382",
      "3114410963",
      "2741271183",
      "1710977250",
      "2363104791",
      "2307297070",
      "1559212036",
      "2851058261",
      "1630943713",
      "1564026768",
      "1866298408",
      "2545327648",
      "3295021220",
      "2971190303",
      "2471347750",
      "2572331007",
      "2116157322",
      "1895432270",
      "2780914191",
      "2937138060",
      "1832448183",
      "2931560672",
      "2723807644",
      "3397937842",
      "3031784065",
      "2990236173",
      "2789302074",
      "2155726353",
      "3171576913",
      "1991570984",
      "2536888090",
      "3200745813",
      "1680019590",
      "2614334381",
      "2507204412",
      "2166325582",
      "2918418331",
      "2469448088",
      "3125203834",
      "2393499239",
      "1828439124",
      "1797720064"
  ],
  "steamWsServerMods": [
    "2874589934",
    "3277130230",
    "2276010135"
  ],
  "updateModsBeforeServerStart": true,
  "updateModsOnStartup": true,
  "validateModsAfterUpdate": false,
  "updateServerBeforeServerStart": true,
  "updateServerOnStartup": true,
  "validateServerAfterUpdate": false,
  "linkModDirs": false,
  "copyModDeepCompare": false,
  "updateModsMaxBatchSize": 5,
  "updateModsMaxBatchFileSize": 1000000000,
  "events": [
    {
      "name": "Restart every 8 hours",
      "type": "restart",
      "cron": "0 0,4,12,20 * * *"
    },
    {
      "name": "Restart Notification (1h)",
      "type": "message",
      "cron": "0 3,11,19 * * *",
      "params": [
        "Server restart in 60 minutes"
      ]
    },
    {
      "name": "Restart Notification (30m)",
      "type": "message",
      "cron": "30 3,11,19 * * *",
      "params": [
        "Server restart in 30 minutes"
      ]
    },
    {
      "name": "Restart Notification (15m)",
      "type": "message",
      "cron": "45 3,11,19 * * *",
      "params": [
        "Server restart in 15 minutes"
      ]
    },
    {
      "name": "Restart Notification (10m)",
      "type": "message",
      "cron": "50 3,11,19 * * *",
      "params": [
        "Server restart in 10 minutes"
      ]
    },
    {
      "name": "Restart Notification (5m)",
      "type": "message",
      "cron": "55 3,11,19 * * *",
      "params": [
        "Server restart in 5 minutes. The server is now locked. Please log out."
      ]
    },
    {
      "name": "Restart Lock (5m)",
      "type": "lock",
      "cron": "55 3,11,19 * * *"
    },
    {
      "name": "Restart Kick (2m)",
      "type": "kickAll",
      "cron": "58 3,11,19 * * *"
    }
  ],
  "metricPollIntervall": 10000,
  "metricMaxAge": 2592000000,
  "hooks": [],
  "ingameReportEnabled": true,
  "ingameReportExpansionCompat": true,
  "ingameReportViaRest": false,
  "ingameReportIntervall": 30,
  "dataDump": false,
  "serverCfg": {
    "hostname": "Unser Server Name",
    "maxPlayers": 20,
    "motd": [],
    "motdInterval": 1,
    "password": "supergeheimespasswort",
    "passwordAdmin": "supergeheimespasswort",
    "enableWhitelist": 0,
    "BattlEye": 1,
    "verifySignatures": 2,
    "forceSameBuild": 1,
    "guaranteedUpdates": 1,
    "allowFilePatching": 0,
    "steamQueryPort": 27016,
    "maxPing": 200,
    "speedhackDetection": 1,
    "disableVoN": 0,
    "vonCodecQuality": 20,
    "disable3rdPerson": 0,
    "disableCrosshair": 0,
    "disableBaseDamage": 0,
    "disableContainerDamage": 0,
    "disableRespawnDialog": 0,
    "respawnTime": 5,
    "enableDebugMonitor": 1,
    "disablePersonalLight": 1,
    "lightingConfig": 0,
    "serverTime": "SystemTime",
    "serverTimeAcceleration": 12,
    "serverNightTimeAcceleration": 1,
    "serverTimePersistent": 0,
    "loginQueueConcurrentPlayers": 5,
    "loginQueueMaxPlayers": 500,
    "simulatedPlayersBatch": 20,
    "multithreadedReplication": 1,
    "networkRangeClose": 20,
    "networkRangeNear": 150,
    "networkRangeFar": 1000,
    "networkRangeDistantEffect": 4000,
    "defaultVisibility": 1375,
    "defaultObjectViewDistance": 1375,
    "instanceId": 1,
    "storeHouseStateDisabled": false,
    "storageAutoFix": 1,
    "timeStampFormat": "Short",
    "logAverageFps": 30,
    "logMemory": 30,
    "logPlayers": 30,
    "logFile": "server_console.log",
    "adminLogPlayerHitsOnly": 0,
    "adminLogPlacement": 0,
    "adminLogBuildActions": 0,
    "adminLogPlayerList": 0,
    "Missions": {
      "DayZ": {
        "template": "dayzOffline.expansion.chernarusplus"
      }
    },
    "enableCfgGameplayFile": 0
  }
}
```

Wenn jetzt der Container neu gestartet wird, sollten alle Mods installiert werden und der Server starten.
Ich bin mir grad nicht sicher ob der Server Manager einen Autoreload hat wenn die Konfiguration angepasst wird. Aber zur Sicherheit einmal

```bash
docker compose restart
```


Wir können uns nun die Weboberfläche unter `localhost:2080` anschauen und uns dort mit den Anmeldedaten einloggen. Grundsätzlich sollte der Server jetzt schon funktionieren.

## Freigaben am Router

Damit der Server nun aus dem Internet erreichbar ist, müssen wir noch die erforderlichen Ports freigeben. 
Das hat bei mir ewig gedauert, aber mit folgenden Freigaben funktioniert es:

![Portfreigaben FritzBox](image.png)

Sind die Ports freigegeben, sollten wir nun per DayZ-Launcher mit dem Server connecten können.


## Weboberfläche

Die Weboberfläche befindet sich aktuell noch im Heimnetz. Damit Leute außerhalb deines Heimnetzes (insbesondere ich) darauf zugreifen können, gibt es zwei Möglichkeiten:

1. Wir machen die Seite aus dem Internet heraus aufrufbar
   1. Dafür brauchen wir: Webserver mit integrierter Reverse Proxy (wie z.B. Swag, Traefik oder Pangolin) und einem Programm dass DynDNS an Strato übermittelt (z.B. ddclient)
   2. Eine eigene Domain (gibts bei STRATO für 12€ im Jahr)
   3. Ich pack auf den Stick auch mein Setup mit SWAG, ich finde aber auch Pangolin sehr attraktiv
2. Wir setzen einen VPN auf, sodass man in dein Heimnetzwerk tunneln kann 
   1. Dafür brauchen wir: Wireguard oder Pangolin

Wie wir es machen, es muss ja nicht sofort sein. Ich kann das aber auch gerne für uns aufsetzen.

# 6. Sonstiges

## Weitere Docker-Container

Folgende Container würde ich noch sehr empfehlen:

* [dozzle](https://dozzle.dev/)
  * Logfile Management und Realtime Ansicht
* [dockge](https://github.com/louislam/dockge)
  * Grafische Oberfläche für Docker Container
* [tinyauth](https://tinyauth.app/)
  * Sehr einfach zu konfigurierende Authentifizierung für z.B. Webseiten
* [glances](https://github.com/nicolargo/glances)
  * Überwacht und zeigt Ressourcesn aus dem System
* [rustdesk](https://github.com/rustdesk/rustdesk)
  * Selbstgehostete Variante für Teamviewer
