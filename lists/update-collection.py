#!/usr/bin/env python3
"""Refresh the public BGG collection without replacing data on upstream failure."""

import argparse
import json
import os
from pathlib import Path
import tempfile
import time
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET


URL = "https://boardgamegeek.com/xmlapi2/collection?username=sharkdp&own=1&stats=1"


def parse_collection(data):
    root = ET.fromstring(data)
    if root.tag != "items" or root.find("error") is not None:
        raise ValueError("Invalid BGG collection response")
    items = root.findall("item")
    if int(root.attrib["totalitems"]) != len(items):
        raise ValueError("Incomplete BGG collection response")
    games = []
    for item in items:
        stats = item.find("stats")
        name = item.findtext("name")
        if stats is None or not name:
            raise ValueError("Missing BGG game data")
        rating = stats.find("rating/average")
        if rating is None:
            raise ValueError("Missing BGG rating")
        value = rating.attrib["value"]
        games.append({
            "bggid": int(item.attrib["objectid"]),
            "name": name,
            "year": int(item.findtext("yearpublished") or 0),
            "minplayers": int(stats.attrib["minplayers"]),
            "maxplayers": int(stats.attrib["maxplayers"]),
            "time": int(stats.attrib["playingtime"]),
            "thumb": item.findtext("thumbnail") or "",
            "rating": 0.0 if value == "N/A" else float(value),
        })
    return games


def fetch_collection(token):
    request = urllib.request.Request(URL, headers={
        "Authorization": f"Bearer {token}",
        "User-Agent": "david-peter.de collection updater",
    })
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                if response.status == 200:
                    return parse_collection(response.read())
                if response.status != 202:
                    raise ValueError("Unexpected BGG response status")
        except urllib.error.HTTPError as error:
            if error.code not in (429, 500, 502, 503, 504):
                raise
        except urllib.error.URLError:
            pass
        if attempt < 4:
            time.sleep(15 * (attempt + 1))
    raise RuntimeError("BGG collection unavailable after five attempts")


def write_collection(output, games):
    # Encode first: invalid/non-finite data must not replace the previous file.
    data = json.dumps(games, ensure_ascii=False, allow_nan=False) + "\n"
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8",
                                         dir=output.parent, delete=False) as file:
            temporary = Path(file.name)
            file.write(data)
            file.flush()
            os.fchmod(file.fileno(), 0o644)
        os.replace(temporary, output)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--token-file", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    token = args.token_file.read_text().strip()
    if not token or "\n" in token or "\r" in token:
        raise ValueError("Invalid BGG token file")
    games = fetch_collection(token)
    write_collection(args.output, games)
    print(f"Published {len(games)} board games")


if __name__ == "__main__":
    main()
