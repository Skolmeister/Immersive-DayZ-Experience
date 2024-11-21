import discord
from discord.ext import commands
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from dotenv import load_dotenv
import os
import subprocess
import datetime, time
import re

# Lade environment und setze variablen
load_dotenv()
directory_path = 'logs' 
TARGET_CHANNEL_ID = 1271160668770275429  
MESSAGE_CONTENT = "Hier sind die neuesten Modupdates:"

# Initialisiere den Bot
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)

# Funktion zum durchsuchen der Mods
def search_updated_mods():
        subprocess.Popen(["Rscript", 
                  os.getcwd() + "/find_last_updates.r"])
        return

# Funktion zum finden des letzten Logs
def get_latest_file_by_timestamp(directory):
    # Definiere das Muster für den Zeitstempel im Dateinamen
    timestamp_pattern = r"(\d{8}_\d{6})_mod_updates\.log"
    
    latest_file = None
    latest_timestamp = None

    for filename in os.listdir(directory):
        # Überprüfen, ob der Dateiname dem Muster entspricht
        match = re.search(timestamp_pattern, filename)
        if match:
            # Extrahiere den Zeitstempel-String
            timestamp_str = match.group(1)
            # Konvertiere den Zeitstempel in ein datetime-Objekt
            timestamp = datetime.datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")

            # Vergleiche mit dem bisher neuesten Zeitstempel
            if latest_timestamp is None or timestamp > latest_timestamp:
                latest_timestamp = timestamp
                latest_file = filename

    if latest_file:
        return os.path.join(directory, latest_file)
    else:
        return None


# Scheduler einrichten
scheduler = AsyncIOScheduler()

# Funktion zum Senden der Nachricht
async def send_daily_message():
    channel = bot.get_channel(TARGET_CHANNEL_ID)
    if channel:
        # Generiere die Mod-Datei
        search_updated_mods()
        # Warte bis alles generiert wurde
        time.sleep(60)
        # Finde das neueste Logfile
        latest_file = get_latest_file_by_timestamp(directory_path)
        # Sende die Nachricht mit Anhang
        await channel.send(MESSAGE_CONTENT)
        with open(latest_file, 'rb') as fp:
            await channel.send(file=discord.File(fp, 'mod.log'))
    else:
        print("Channel wurde nicht gefunden. Bitte überprüfe die Channel-ID.")

# Ereignis für den Scheduler hinzufügen, um täglich um 12 Uhr zu senden
scheduler.add_job(send_daily_message, CronTrigger(hour=12, minute=0))

@bot.event
async def on_ready():
    print(f'Bot ist eingeloggt als {bot.user}')
    # Starte den Scheduler
    scheduler.start()

# Zusätzliches Event zur manuellen abgrage
@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    if message.content.startswith('?modupdates'):
        await message.channel.send('Searching for updates, this will take a minute!')
        # Generiere die Mod-Datei
        search_updated_mods()
        # Warte bis alles generiert wurde
        time.sleep(60)
        await message.channel.send('Here are the latest updates!')
        latest_file = get_latest_file_by_timestamp(directory_path)
        with open(latest_file, 'rb') as fp:
            await message.channel.send(file=discord.File(fp, 'mod.log'))

# Starte den Bot
bot.run(os.getenv("DISCORD_BOT"))
