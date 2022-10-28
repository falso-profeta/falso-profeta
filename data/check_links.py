# Verifica links mortos no arquivo data.json
import sys
import typer
import json
import asyncio

import aiohttp

from time import perf_counter
from typing import Dict, Tuple
from pathlib import Path

sys.path.append(Path(__file__).parent)
from config import FILES, PATH, SOURCES, URL_REGEX



def read_links(data):
    for story in data:
        name = story['name']
        yield f'{name}.youtube', story['youtube']

        for j, rant in enumerate(story["rants"], start=1):
            yield f'{name}.rants.{j}', rant['source']['url']     
    
        for j, ev in enumerate(story["events"], start=1):
            yield f'{name}.events.{j}.image', ev['image']     
            yield f'{name}.events.{j}.url', ev['source']['url']     
        


async def verify_links(links: Dict[str, str]):
    async def is_valid_link(key: str, link: str, session) -> Tuple[str, bool]:
        if not link.startswith('http'):
            return (key, link, False)

        try:
            response = await session.get(link)
        except Exception as ex:
            print(ex)
            return (key, link, False)

        return (key, link, response.status // 10 not in (20, 30)) 

    async with aiohttp.ClientSession() as session: 
        tasks = (asyncio.create_task(is_valid_link(k, v, session)) for k, v in links.items())
        results = {k: v for k, v, has_error in await asyncio.gather(*tasks) if has_error} 
    
    return results


def main(path: Path = PATH.parent / "static" / "data.json"):
    links = dict(read_links(json.load(path.open('r'))))    
    print(f'Found {len(links)} links. Testing for broken links.')

    start = perf_counter()
    results = asyncio.run(verify_links(links))
    stop = perf_counter()
    print("time taken:", stop - start)

    print('Failed URLS:')
    for k, url in results.items():
        print(f'- {k}:\n      {url}')
            


if __name__ == "__main__":
    typer.run(main)
