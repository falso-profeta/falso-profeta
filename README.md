FALSO PROFETA
=============

Site dedicado à mostrar algumas verdades sobre o presidente Jair Messias Bolsonaro. Código caótico, feito as pressas, misturando inglês e português, mas os usuários provavelmente não vão perceber isto ;-)


Instalação
----------

O site possui conteúdo estático e está hospedado no Github pages e no CloudFlare pages.


Desenvolvimento
---------------

Instale nix e direnv para construir o ambiente automaticamente ao entrar no diretório.

Se quiser construir tudo manualmente, instale as seguintes dependências:

- elm 0.19.1
- sassc
- python + inkove + toolz + yaml
- e mais algumas outras listadas no arquivo shell.nix.

É possível reconstruir o site usando comandos do invoke em um ambiente com as dependências necessárias instaladas (``inv -l`` para ver a lista de comandos).