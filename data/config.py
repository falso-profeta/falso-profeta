from pathlib import Path
import re
import sys

PATH = Path(__file__).parent
FILES = [
    "ira",
    "avareza",
    "luxuria",
    "gula",
    "economia",
    "racismo",
    "intolerancia",
    # 'preguica',
    "imigrantes",
    "lgbt",
    "ditadura",
    "presos",
]
SOURCES = {
    "youtube.com": "Youtube",
    "folha.uol.com.br": "Folha de São Paulo",
    "www1.folha.uol.com.br": "Folha de São Paulo",
    "acervo.folha.com.br": "Folha de São Paulo",
    "bbc.com": "BBC Brasil",
    "g1.globo.com": "G1",
    "oglobo.globo.com": "O Globo",
    "terra.com.br": "Terra",
    "brasil.elpais.com": "El País",
    "metro1.com.br": "Metro 1",
    "revistaladoa.com.br": "Revista Lado A",
    "portaldiariodonorte.com.br": "Portal Diário do Norte",
    "brasildefato.com.br": "Brasil de Fato",
    "jovempan.uol.com.br": "Jovem Pan",
    "congressoemfoco.uol.com.br": "Congresso em Foco",
    "metropoles.com": "Metrópoles",
    "cartacapital.com.br": "Carta Capital",
    "justificando.com": "Justificando",
    "huffpostbrasil.com": "Huffington Post Brasil",
    "mossorohoje.com.br": "Mossoró Hoje",
    "noticias.uol.com.br": "UOL",
    "diariodepernambuco.com.br": "Diário de Pernambuco",
}

# Regular expressions
HEADER_REGEX = re.compile(r"^#\s*([^\n]*)")
URL_REGEX = re.compile(r"^https?://(www\.)?([^/]+)/")

# Check all directories are registered
ALL_PATHS = {
    p.name for p in PATH.iterdir() if p.is_dir() and not p.name.startswith("_")
}
if missing := (ALL_PATHS - set(FILES)):
    print(f"Please register the following paths: {missing}", file=sys.stderr)
    FILES.extend(sorted(missing))
if invalid := (set(FILES) - ALL_PATHS):
    raise SystemError(f"Could not find the following stories: {invalid}")
