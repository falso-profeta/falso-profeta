# Verifica links mortos no arquivo data.json
import sys
import typer
import json
import asyncio

import aiohttp

from time import perf_counter
from typing import Sequence, Tuple
from pathlib import Path

sys.path.append(Path(__file__).parent)
from config import FILES, PATH, SOURCES, URL_REGEX


async def is_valid_link(link: str, session) -> Tuple[str, bool]:
    response = session.get(link)
    return (link, response.status_code // 10 in (20, 30)) 


def read_links(data):
    links = set()
    for story in data:
        print(story)
    return links

async def verify_links(links: Sequence[str]):
    async with aiohttp.ClientSession() as session: 
        tasks = (asyncio.create_task(is_valid_link(x, session)) for x in links)
        results = dict(await asyncio.gather(*tasks)) 
    return results


def main(path: Path = PATH / "static" / "data.json"):
    data = json.load(path.open('r'))
    links = read_links()    
    print(f'Found {len(links)} links. Testing for broken links.')

    start = perf_counter()
    asyncio.run(verify_links(links))
    stop = perf_counter()
    print("time taken:", stop - start)


if __name__ == "__main__":
    typer.run(main)
