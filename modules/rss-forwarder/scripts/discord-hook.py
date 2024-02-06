#!/usr/bin/env python3

import sys
import json
import argparse
import requests
from bs4 import BeautifulSoup

def process_entry(discord_url, entry):
    title = entry["title"] if "title" in entry else ""
    description = entry["description"] if "description" in entry else ""
    if description != "":
        soup = BeautifulSoup(description, features="html.parser")
        description = soup.get_text()
    link = entry["link"] if "link" in entry else ""

    # TODO: Add link preview
    # https://discord.com/developers/docs/resources/webhook
    r = requests.post(
        discord_url, 
        data={"content": f"{title}: {description.replace('— Permalien', '')}\n{link}".replace('\n\n','\n')}
    )
    print("Sent request to discord hook")
    if r.status_code >= 400:
        print(r.text)

if __name__ == "__main__":
    app = argparse.ArgumentParser(prog='discord-hook')
    app.add_argument('--url', help='Discord Webhook url')
    args = app.parse_args()

    for line in sys.stdin:
        line = line.rstrip()
        process_entry(args.url, json.loads(line))
