# Server Files für den Immersive DayZ Experience Server

Hier wollen wir die Server-Files für den DayZ Server hosten und bearbeiten.
Zugriff erfolgt auf Einladung von mir.

# Setup Git

Neben eurem persönlichen GitHub-Account benötigt ihr noch eine Installation von `git` auf eurem lokalen Rechner.
Git könnt ihr einfach [hier](https://git-scm.com/download/win) downloaden und anschließend mit den Standardeinstellungen installieren. Nach der Installation solltet ihr den PC einmal neu starten.

# Authentifizierung zwischen eurem PC und GitHub

Ihr könnt euch bei Github entweder per https (dann öffnet sich ein Pop-Up in dem ihr eure Nutzerdaten eigeben müsst) oder komfortabler per ssh authentifizieren.
Für die Authentifizierung per ssh folgt am besten [dieser Anleitung](https://docs.github.com/de/enterprise-cloud@latest/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Anschließend könnt ihr das Projekt in einen Ordner eurer Wahl auf eurem PC klonen.

Ich habe folgendes Setup:

```
-- C:/Users/alexa
  -- projects
    -- Projekt A
    -- Projekt B
    -- ...
  -- .ssh
  -- ...
```

Wenn ihr meine Einstellungen beibehalten wollt, nutzt ihr folgende Befehle (in CMD oder Powershell):

* `mkdir projects`
* `cd projects`
* `git clone -v git@github.com:{{EUER_USERNAME}}/Immersive-DayZ-Experience.git` Hier bitte {{EUER_USERNAME}} durch euren Usernamen (ohne Klammern) ersetzten

Anschließend sollte die Ordnerstruktur so aussehen:

```
-- C:/Users/alexa
  -- projects
    -- Immersive-DayZ-Experience
      -- readme.md
  -- .ssh
  -- ...
```

# Arbeiten mit VSCode und git

Wenn ihr VSCode bereits installiert habt, könnt ihr nun über Powershell oder CMD direkt VSCode im korrekten Ordner starten:

* Dafür (falls ihr noch nicht mit dem Terminal in den Ordner navigiert habt) `cd /pfad/zu/eurem/ordner`
* Anschließend könnt ihr VSCode mit `code .` öffnen
* Alternativ geht auch alles in einem Kommando: `code /pfad/zu/eurem/ordner`

In VSCode selbst gibt es ein Plugin für git, in dem ihr Änderungen leicht sehen und nachverfolgen, und auch per GUI anstatt Kommandozeile arbeiten könnt:

![Git Integration](/image.png)

Für eine Kurzeinführung in git kann ich sonst [diesen Artikel](https://rogerdudler.github.io/git-guide/) empfehlen. Ich würde aber vorschlagen dass wir uns beim ersten mal gemeinsam zusammensetzen.