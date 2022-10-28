#
# Extrai dados dos markdown e gera o arquivo data.json
# Script feito às pressas misturando inglês e português ;-)
#
# Dependências:
#   pip install toolz pyyaml
#
import json
import sys
import toolz
from collections import deque
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


def update_sw(files):
    lines = (f"    {{ url: {file}, revision: null }}, " for file in files)
    src = "\n".join(lines)

    with open(PATH.parent / "sw-template.js") as fd:
        src = fd.read().replace("$URLS", src)

    with open(PATH.parent / "sw.js", "w") as fd:
        fd.write(src)


def parse_text(st: str) -> dict:
    """
    Convert Markdown data to JSON
    """

    paragraphs: deque[deque[str]] = toolz.pipe(
        # Linhas
        st.strip().splitlines(),
        # Remove comentários
        lambda ls: (ln for ln in ls if not ln.lstrip().startswith("//")),
        # Divide em seções separadas por linhas em branco
        lambda xs: toolz.partitionby(lambda ln: not ln.strip(), xs),
        # Aproveita apenas os blocos de linha com conteúdo e
        # transforma em deques()
        lambda xs: [clean_ws(deque(part)) for part in xs][0::2],
        # Cria uma deque de blocos
        deque,
    )

    data = {}

    # Extract title from first paragraph
    title = paragraphs.popleft()[0].removeprefix("#").strip()
    if title.endswith(")"):
        title, _, source = title.partition("(")  #
        title = title.strip()
        source = source.strip("()")
    else:
        source = None
    data["utter"] = title or ""
    data["context"] = source or ""

    # Metadata
    meta = safe_load("\n".join(paragraphs.popleft()))
    data["youtube"] = normalize_youtube_embed(meta["video"] or "").replace(
        "watch?v=", "embed/"
    )

    # Rants
    data["rants"] = rants = []
    for link in meta.get("outras") or ():
        rants.append(parse_rant(link))

    # Bible quotation
    bible = clean_ws(paragraphs.popleft())
    data["ref"] = bible.pop().lstrip(" -") or ""
    data["bible"] = "\n".join(bible) or ""

    # Other stories
    data["events"] = events = []
    while paragraphs:
        event = {}
        events.append(event)
        event["title"] = paragraphs.popleft()[0].removeprefix("##").strip()
        meta = safe_load("\n".join(paragraphs.popleft()))
        event["text"] = " ".join(paragraphs.popleft())
        event["image"] = meta["imagem"]
        event["source"] = parse_source(meta["url"])

    return data


def parse_rant(rant: str):
    text, _, source = rant.rpartition("<")
    source = source.rstrip(">")
    text = text.strip()
    return {"text": text, "source": parse_source(source)}


def parse_source(source: str):
    source = source.strip("<>")
    try:
        domain = URL_REGEX.match(source).group(2)
    except AttributeError:
        raise ValueError(f"invalid source: {source!r}")
    try:
        name = SOURCES[domain]
    except KeyError:
        print(f"WARNING: unknown source: {domain}", file=sys.stderr)
        name = domain
    return {"name": name, "url": source}


def normalize_youtube_embed(link: str) -> str:
    link, sep, opts = link.partition("?")
    if sep:
        suffix = ""
        parts = opts.partition("&")
        for i, part in enumerate(parts):
            if part.startswith("v="):
                part = part.removeprefix("v=")
                link = link.removesuffix("watch") + f"embed/{part}"
            elif part.startswith("time_continue="):
                part = part.removeprefix("time_continue=")
                suffix = f"&start={part}"
            else:
                suffix += "&" + part
        suffix = suffix.strip("& ")
        if suffix:
            link += "?" + suffix
        link = link
    return link


def main():
    result = []
    bg_files = []

    for path in FILES:
        with open(PATH / path / "main.md") as fd:
            src = fd.read()
            try:
                data = parse_text(src)
                data["name"] = path
                data["image"] = f"/static/bg-{path}.jpg"
            except Exception as exc:
                print(f"\nerror({path}): {exc}\n\n", file=sys.stderr)
                raise
            else:
                result.append(data)

        with open(PATH / path / "bg.jpg", "rb") as source:
            with open(PATH.parent / "static" / f"bg-{path}.jpg", "wb") as dest:
                dest.write(source.read())

        bg_files.append(f'"./static/bg-{path}.jpg"')

    print(json.dumps(result, indent=2))
    update_sw(bg_files)


if __name__ == "__main__":
    main()
