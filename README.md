# ALNAIR — REBORN (R6, primeira pessoa)

**Estado local em 22/11/2026:** mundo e menu refeitos, visual de personagens migrado para o R6 quadradão clássico da Roblox. As raças humano/bruxa/morto-vivo/elfo e classes guerreiro/assassino/mago/lutador/samurai mantêm seus visuais próprios por roupa e acessórios, sem corpos R15 importados. Exploração em primeira pessoa com equipamento visível. Progressão própria preservada. Consulte docs/REBUILD_VESTERIA_FIRSTPERSON.md.

**Build de arquivos (sem Studio):** C:\Users\bartk\AppData\Local\Programs\Rojo\rojo.exe build default.project.json -o build\Alnair-reborn-R6.rbxl. O Roblox Studio não foi aberto nem usado para testar nesta etapa; aguardar autorização do proprietário para testagem e screenshots.

---

## Registro histórico (versões antigas)

# ALNAIR

RPG de fantasia em mundo aberto, criado no Roblox Studio com Luau e Rojo.

## Prototipo visual 0.4 - experimental

- Corpo humanoide organico importado da Quaternius, convertido em R15 pelo Avatar Setup do Roblox.
- O rig com 15 MeshParts, Humanoid e articulacoes foi salvo em src/shared/AlnairRiggedBody.rbxmx.
- A previa em ViewportFrame passou a usar as malhas originais; cabelos, barba e orelhas sao MeshParts externos.
- Camera cinematografica de menu, camera em terceira pessoa e corrida com Shift; cutscene anterior mantida.
- FaceControls e usado para presets de expressao quando o modelo permite animacao facial.
- Prototipo: alguns detalhes de enquadramento do preview, roupas e armas 3D precisam de validacao visual antes da publicacao.

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
2. Mais simples: execute ABRIR-ALNAIR.cmd para compilar e abrir o jogo diretamente.
   Alternativamente, na pasta do projeto, execute em PowerShell:
   C:\Users\bartk\AppData\Local\Programs\Rojo\rojo.exe build default.project.json -o build\Alnair.rbxl
3. Abra build\Alnair.rbxl no Roblox Studio e clique em Play.
4. Para sincronização ao vivo, execute SINCRONIZAR-ROJO.cmd ou, no terminal:
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
