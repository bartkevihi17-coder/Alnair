# Alnair 0.5 — Biblioteca visual importada

O jogo usa malhas 3D **baixadas e importadas de pacotes prontos**, não feitas com Parts geométricas. A seleção foi feita para funcionar no Roblox Studio e ser reutilizável pelo Rojo.

## Catálogo integrado

| Categoria | Modelos reutilizáveis | Peças MeshPart importadas | Exemplos |
|---|---:|---:|---|
| NATURE | 20 | 37 | BirchTree, CommonTree, PineTree, Bush, Flowers, Grass, Rock_Moss |
| VILLAGE | 18 | 97 | House, Inn, Blacksmith, Stable, Well, Bonfire, MarketStand, Mill |
| DUNGEON | 14 | 31 | Entrance, Chest, Column, Torch, Bones, ModularStoneWall |
| FORTRESS | 7 | 13 | Tower, TallWall, Bridge, WallEntrance, WatchTowerWRoof |
| ITEMS | 7 | 19 | Armor, Sword, Potion, Coin, Chest |
| ACTORS | 6 | 19 | orc, skeleton, witch, warden, horse, dragon |
| **Total** | **72** | **216** | |

O Studio gerou IDs reais (`rbxassetid://...`) durante a importação. Os assets estão salvos em `src/shared/AlnairArtV05.rbxmx` e são lidos pelo `ArtAssets.lua`. A montagem é do próprio jogo, sem scripts de terceiros.

## Locais onde foram integrados

- Vale das Cinzas: árvores, arbustos, mato, flores, rochas, trilhas, ruínas, casas e torres.
- Nexo das Estrelas: edifícios medievais, torres, colunas, passagens e NPCs feitos a partir do avatar 3D já importado.
- Arena: torres/muralhas medievais com hitboxes invisíveis.
- Cripta: colunas, portões, paredes modulares, baús, ossos, tochas e candelabros.
- Ilhas suspensas e montanhas: rochas e árvores importadas sobre os terrenos com colisões preservadas.
- Inimigos: orc, esqueleto, bruxa, vigia e dragão passam a clonar prefabs 3D reais; sua lógica de combate permanece no servidor.
- Montaria: cavalo e dragão 3D soldados ao personagem, preservando os comandos de movimento.

## Licenciamento e procedência

**Quaternius — CC0 1.0:**
- [Catálogo e licenças dos pacotes](https://github.com/trebeljahr/quaternius-showcase/blob/main/LICENSES.md) — cada um dos packs abaixo aparece como CC0;
- [Ultimate Nature Pack](https://quaternius.com/packs/ultimatenature.html)
- [Medieval Village Pack](https://quaternius.com/packs/medievalvillage.html)
- [Modular Dungeon Pack](https://quaternius.com/packs/medievaldungeon.html)
- [Modular Buildings](https://quaternius.com/packs/medievaldungeon.html) e biblioteca medieval do showcase;
- [Ultimate RPG Pack](https://quaternius.com/packs/ultimaterpg.html)
- [Quaternius Ultimate Monsters](https://quaternius.com/packs/ultimatemonsters.html) e outras versões CC0;
- [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) (avatar R15 usado na versão anterior).

**Dragão alternativo estático:** [Low Poly Dragon — Grab3D](https://grab3d.com/models/creatures/low-poly-dragon/), página declara CC0. O pack de criatura importado pelo Studio também usou um Dragon Quaternius da coleção existente.

**Fontes locais:** `assets/vendor/ArtV05/`, `assets/vendor/Enemies/`, `assets/vendor/Quaternius/`. Os arquivos GLB brutos são mantidos na pasta de trabalho, fora do Git, com o manifesto `assets/vendor/ArtV05/manifest.json` e rastreio dos downloads. As bibliotecas já importadas são preservadas no Git.

## Limites conhecidos

- A geometria e as texturas foram importadas. As **animações próprias de cada criatura e montaria ainda precisam ser conectadas** ao estado de movimento/combate; não confundir ter um mesh com ter animações funcionais.
- Partes grandes de terreno, rampas e plataformas mantêm colisores invisíveis, pois converter a malha de cenário diretamente em colisão pode comprometer navegação e desempenho.
- Os detalhes visuais dependem da disponibilidade dos IDs de malha/textura na conta Roblox usada durante a importação. Conferir permissões na publicação final.
- Não há garantia de correção de todos os módulos do jogo até realizar uma partida completa no Studio autenticado, com Output monitorado.
- O painel de desenvolvimento e o estado de testes não devem ser confundidos com lançamento público.

## Compilação

`powershell -NoProfile -ExecutionPolicy Bypass -File tests/run_checks.ps1`

O Rojo gera uma experiência `.rbxlx` com a biblioteca incluída, independente do projeto temporário usado no importador.
