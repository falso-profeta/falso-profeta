import json
import sys 
import toolz
from collections import deque
from rich import inspect
from yaml import safe_load
from pathlib import Path

sys.path.append(Path(__file__).parent)
from config import FILES, PATH, SOURCES, URL_REGEX


def clean_ws(xs: deque[str]) -> deque[str]: 
    while xs and xs[0].isspace():
        xs.popleft()
    while xs and xs[-1].isspace():
        xs.pop()
    return xs


def parse_text(st: str) -> dict:
    """
    Convert Markdown data to JSON
    """

    paragraphs: deque[deque[str]] = toolz.pipe(
        st.strip().splitlines(),
        lambda xs: toolz.partitionby(lambda ln: not ln.strip(), xs),
        lambda xs: [clean_ws(deque(part)) for part in xs][0::2],
        deque,
    ) 
    
    data = {}
    
    # Extract title from first paragraph
    title = paragraphs.popleft()[0].removeprefix('#').strip()
    if title.endswith(')'):
        title, _, source = title.partition('(')
        title = title.strip()
        source = source.strip('()')
    else:
        source = None
    data['utter'] = title
    data['context'] = source
    
    # Metadata
    meta = safe_load('\n'.join(paragraphs.popleft()))
    data['youtube'] = meta['video']

    # Rants
    data['rants'] = rants = []
    for link in meta.get('outras') or ():
        rants.append(parse_rant(link))

    # Bible quotation
    bible = clean_ws(paragraphs.popleft())
    data['ref'] = bible.pop().lstrip(' -')
    data['bible'] = '\n'.join(bible)
    
    # Other stories
    data['events']  = events = []
    while paragraphs:
        event = {}
        events.append(event)
        event['title'] = paragraphs.popleft()[0].removeprefix('##').strip()
        meta = safe_load('\n'.join(paragraphs.popleft()))
        event['text'] = ' '.join(paragraphs.popleft())
        event['image'] = meta['imagem']
        event['source'] = parse_source(meta['url'])

    return data

def parse_rant(rant: str):
    text, _, source = rant.rpartition('<')
    source = source.rstrip('>')
    text = text.strip()
    return {'text': text, 'source': parse_source(source)}


def parse_source(source: str):
    source = source.strip('<>')
    try:
        domain = URL_REGEX.match(source).group(2)
    except AttributeError:
        raise ValueError(f'invalid source: {source!r}')
    try:
        name = SOURCES[domain]
    except KeyError:
        print(f'WARNING: unknown source: {domain}', file=sys.stderr)
        name = domain
    return {'name': name, 'url': source}



from pprint import pprint 

result = []
for path in FILES:
    with open(PATH / path / 'main.md') as fd:
        src = fd.read()
        try:
            data = parse_text(src)
            data['image'] = f'/static/bg-{path}.jpg'
        except Exception as exc:
            raise  
        else:
            result.append(data)

    with open(PATH / path / 'bg.jpg', 'rb') as source:
        with open(PATH.parent / 'static' / f'bg-{path}.jpg', 'wb') as dest:
            dest.write(source.read())
            
print(json.dumps(result, indent=2))