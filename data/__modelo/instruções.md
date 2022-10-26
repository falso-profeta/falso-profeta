# Como acrescentar ou contribuir com dados para o **Falso profeta**?

Para criar uma nova seção, copie a pasta "data/__modelo" e edite o arquivo `main.md` e acrescente uma imagem de fundo no arquivo `bg.jpg`.

Você pode acrescentar quantas falas na seção `outros` do arquivo e histórias de imprensa na seções sequintes à seção principal. Mantenha a estrutura básica do arquivo e edite as partes entre colchetes.

Entregue o arquivo editado para algum desenvovedor incluir os dados no ambiente de produção.


**AVANÇADO:** Podemos recompilar os arquivos em um ambiente configurado com o nix. Basta digitar `inv build` no terminal do ambiente corretamente configurado para refazer os arquivos elm e o arquivo data.json que alimenta o site a partir das notícias. Se não tiver o nix instalado e quiser apeanas requirar o arquivo data.json a partir de uma atualização das notícias, execute o script `/data/extract.py` utilizando um interpretador do [Python 3](http://python.org) relativamente recente.