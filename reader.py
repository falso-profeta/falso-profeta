import re
import json
from pprint import pprint
from yaml import safe_load
import toolz

h1_regex = re.compile(r'^#\s*([^\n]*)')


def clean_title(st):
    return st.strip('"\' \n')


def remove_empty_lines(st):
    return '\n'.join(line for line in st.splitlines() if not line.isspace())


def parse_re(regex, doc):
    m = regex.match(doc)
    if m is None:
        raise TypeError('do not match document')

    i, j = m.span()
    return m.group(1), doc[j:]


def parse_document(doc):
    title, doc = parse_re(h1_regex, doc)
    title = clean_title(title)
    section, sep, doc = doc.partition('\n##')

    lines = toolz.remove(str.isspace, section.splitlines())
    quote, data = toolz.partitionby(lambda x: x.startswith(' '), lines)

    quote = '\n'.join(quote)
    print(quote)


    print(data)

    return None


def main():
    with open('data.md') as fd:
        data = fd.read()
    documents = [parse_document(x.strip()) for x in data.split('---')]
    with open('data.json', 'w') as fd:
        json.dump(documents, fd)
    pprint(documents)


if __name__ == '__main__':
    main()
