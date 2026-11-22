# ALNAIR

RPG de fantasia em mundo aberto, criado no Roblox Studio com Luau e Rojo.

## Versão 0.1.0 — Fundação jogável

- Menu: Campanha, Sandbox, Co-op (Em breve) e PvP (Em breve).
- Campanha: seleção de Raça → Classe → Aparência.
- Raças: Humano, Bruxo, Morto-vivo e Elfo.
- Classes: Guerreiro (espada e escudo), Assassino (duas adagas), Mago (cajado), Lutador (mãos) e Samurai (katana).
- Presets de rosto, orelhas, cabelo, parte superior, parte inferior, conjuntos e calçados, inclusive descalço.
- Prévia 3D do personagem quadrado padrão.
- Cutscene inicial com opção de pular.
- Primeiro cenário de exploração: ruínas, bosque, trilhas e praça.
- Sandbox: entra no mapa diretamente com configurações padrão.
- Sem combate, NPCs, missões ou multiplayer nesta versão, conforme o escopo inicial.

## Projeto

Pasta: C:\Users\bartk\Desktop\Alnair
GitHub: https://github.com/bartkevihi17-coder/Alnair

## Abrir e testar

1. Conclua a instalação do Roblox Studio.
2. Na pasta do projeto, execute em PowerShell:
   C:\Users\bartk\AppData\Local\Programs\Rojo\rojo.exe build default.project.json -o build\Alnair.rbxl
3. Abra build\Alnair.rbxl no Roblox Studio e clique em Play.
4. Para sincronização ao vivo, execute:
   C:\Users\bartk\AppData\Local\Programs\Rojo\rojo.exe serve default.project.json
   Instale o plugin Rojo 7 no Roblox Studio e clique em Rojo → Connect.
5. Para corpo quadrado clássico também em jogo, em Avatar Settings no Studio selecione Avatar Type R6. A prévia usa R6 e a customização suporta R6 e R15.

O GitHub versiona o código. Publicar o jogo no Roblox é uma ação separada no Studio. A versão 0.1 ainda não salva personagens no DataStore; escolhas duram uma sessão.

## Fluxo Git

git status
git add .
git commit -m "feat: atualizar Alnair"
git push origin main

Para receber mudanças de outra máquina: git pull --rebase origin main.

## Estrutura

- default.project.json: árvore do Rojo.
- src/shared/Catalog.lua: raças, classes e presets.
- src/shared/Appearance.lua: visual e preview do personagem.
- src/server/World.lua: mundo inicial.
- src/server/Bootstrap.server.luau: entrada e validação do servidor.
- src/client/Alnair.client.luau: interface, customização e cutscene.
- docs/ROADMAP.md: próximas etapas.
