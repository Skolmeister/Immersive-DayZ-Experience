import os
import discord
import re
from dotenv import load_dotenv
from discord.ext import commands, tasks
from datetime import datetime
import subprocess, sys
import time

directory_path = 'C:\\Users\\alexa\\projects\\Immersive-DayZ-Experience\\logs' 

def search_updated_mods():
    logpath = "C:\\Users\\alexa\\projects\\Immersive-DayZ-Experience\\logs\\"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_mod_updates.log"
    logfile = logpath + filename
    with open(logfile, "x") as outfile:
        subprocess.Popen(["powershell.exe", 
                  "C:\\Users\\alexa\\projects\\Immersive-DayZ-Experience\\tools\\search_for_updated_mods.ps1"], 
                  stdout=outfile)

load_dotenv()
TOKEN = os.getenv("DISCORD_BOT")
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
            timestamp = datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")

            # Vergleiche mit dem bisher neuesten Zeitstempel
            if latest_timestamp is None or timestamp > latest_timestamp:
                latest_timestamp = timestamp
                latest_file = filename

    if latest_file:
        return os.path.join(directory, latest_file)
    else:
        return None



intents = discord.Intents.default()
intents.message_content = True
# MY_CHANNEL_ID = 1280830474385752127
bot = commands.Bot(command_prefix = "?", intents = intents)
# CLIENT 
# client = discord.Client(intents=intents)

@bot.event
async def on_ready():
    print(f'We have logged in as {bot.user}')

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    if message.content.startswith('?modupdates'):
        await message.channel.send('OK, here are the Mods that have been updated since yesterday!')
        search_updated_mods()
        time.sleep(2)
        latest_file = get_latest_file_by_timestamp(directory_path)
        with open(latest_file, 'rb') as fp:
            await message.channel.send(file=discord.File(fp, 'mod.log'))

bot.run(TOKEN)