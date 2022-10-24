from pathlib import Path
import re

PATH = Path(__file__).parent
FILES = [
    "amor",
    "corrupcao",
    "ditadura",
    "ganancia",
    "imigrantes",
    "intolerancia",
    "presos",
    "racismo",
    "trabalho",
    "violencia",
]
SOURCES = {
    'youtube.com': 'Youtube',
    'folha.uol.com.br': 'Folha de São Paulo',
    'www1.folha.uol.com.br': 'Folha de São Paulo',
    'acervo.folha.com.br': 'Folha de São Paulo',
    'bbc.com': 'BBC Brasil',
    'g1.globo.com': 'G1',
    'oglobo.globo.com': 'O Globo',
    'terra.com.br': 'Terra',
    'brasil.elpais.com': 'El País',
    'metro1.com.br': 'Metro 1',
    'revistaladoa.com.br': 'Revista Lado A',
    'portaldiariodonorte.com.br': 'Portal Diário do Norte',
    'brasildefato.com.br': 'Brasil de Fato',
    'jovempan.uol.com.br': 'Jovem Pan',
    'congressoemfoco.uol.com.br': 'Congresso em Foco',
    'metropoles.com': 'Metrópoles',
    'cartacapital.com.br': 'Carta Capital',
    'justificando.com': 'Justificando',
    'huffpostbrasil.com': 'Huffington Post Brasil',
    'mossorohoje.com.br': 'Mossoró Hoje',
    'noticias.uol.com.br': 'UOL',
    'diariodepernambuco.com.br': 'Diário de Pernambuco',
}

# Regular expressions
HEADER_REGEX = re.compile(r'^#\s*([^\n]*)')
URL_REGEX = re.compile(r'^https?://(www\.)?([^/]+)/')