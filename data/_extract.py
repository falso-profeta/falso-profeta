import toolz
from yaml import safe_load
from _config import FILES, PATH, SOURCES, URL_REGEX


def parse_text(st: str) -> dict:
    """
    Convert Markdown data to JSON
    """

    st = st.strip()
    data = {}

    try:
        # Extract title, meta and stories
        lines = toolz.remove(lambda x: not x or x.isspace(), st.splitlines())
        title, meta, content = toolz.partitionby(lambda x: x.startswith(' '), lines)
        title: str = title[0].strip('# ')    
        meta = safe_load('\n'.join(meta))
        content = '\n'.join(content)

        if title.endswith(')'):
            title, _, source = title.partition('(')
            title = title.strip()
            source = source.strip('(')
        else:
            source = None
        data['title'] = title
        data['image'] = meta['imagem']
        data['text'] = content

        if source:
            data['source'] = {'name': source, 'url': meta['url']}
        else:
            data['source'] = parse_source(meta['url'])
    except:
        print(st)
        raise
    return data


def parse_source(source: str):
    source = source.strip('<>')
    try:
        domain = URL_REGEX.match(source).group(2)
    except AttributeError:
        raise ValueError(f'invalid source: {source!r}')
    name = SOURCES[domain]
    return {'name': name, 'url': source}



from pprint import pprint 

for path in FILES:
    with open(PATH / (path + '.md')) as fd:
        src = fd.read()
        data = parse_text(src)
    pprint(data)