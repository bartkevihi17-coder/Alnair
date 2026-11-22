# Biblioteca de inimigos do Alnair — fontes e licenças

Os arquivos abaixo foram baixados para **`assets/vendor/Enemies/` no desktop**, ainda **não integrados à experiência Roblox publicada**. Não foram adicionados ao repositório remoto como downloads brutos. Antes de usar, importar por 3D Importer no Roblox Studio, revisar mesh/atlas/material, selecionar animações, atribuir corretamente ownership de IDs e ajustar colisões, rig e LOD.

| Arquivo local | Tipo | Origem verificável | Condição |
|---|---|---|---|
| `KayKit_Skeleton_Minion.glb` | esqueleto básico | https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0 | CC0 |
| `KayKit_Skeleton_Warrior.glb` | esqueleto guerreiro | mesma fonte | CC0 |
| `KayKit_Skeleton_Rogue.glb` | esqueleto ladino | mesma fonte | CC0 |
| `KayKit_Skeleton_Mage.glb` | esqueleto mago / variante de bruxa | mesma fonte | CC0 |
| `KayKit_skeleton_texture.png` | atlas de texturas | mesma fonte | CC0 |
| `Skeleton_Quaternius.glb` | esqueleto animado | https://github.com/ilrein/warptracker/blob/main/ASSETS.md | Quaternius Animated Monster Pack (documentado CC0) |
| `Demon_Quaternius.glb` | demônio | mesma fonte | Quaternius Ultimate Monsters (documentado CC0) |
| `Ghost_Quaternius.glb` | fantasma | mesma fonte | Quaternius Ultimate Monsters (documentado CC0) |
| `Orc_Quaternius.glb` | orc | https://github.com/kikoncuo/jevfire/blob/main/web/ASSETS.md | Quaternius Ultimate Monsters (documentado CC0) |
| `DragonEvolved_Quaternius.glb` | draco | https://github.com/crisleyhguimaraes/space-ship/blob/main/docs/ASSETS.md | Quaternius Ultimate Monsters (documentado CC0) |
| `BlueDemon_Quaternius.glb` | demônio azulado | mesma fonte | Quaternius Ultimate Monsters (documentado CC0) |
| `Horse_Quaternius.glb` | cavalo de montaria | mesma fonte | Quaternius (documentado CC0) |

**Notas**: KayKit oferece quatro personagens com rig e mais de 90 animações, com licença CC0 explicitamente no repositório. Os modelos Quaternius aqui são derivados redistribuídos por terceiros; o jogo deve obedecer às condições vigentes de cada asset na fonte original. Não apresentar o produto como criado ou endossado pelos autores. A licença do site Quaternius pode ter políticas adicionais de redistribuição de assets avulsos; por prudência, os arquivos brutos ficam **fora do Git** e não serão revendidos/republicados como biblioteca.

## Fontes adicionais catalogadas (não baixadas)
- Pacote de 50 monstros animados: https://quaternius.com/packs/ultimatemonsters.html
- Pacote de 200+ adereços de fantasia: https://quaternius.com/packs/fantasypropsmegakit.html
- Medieval / dungeon de KayKit: https://kaylousberg.itch.io/kaykit-dungeon-pack
- Orc CC0 Quaternius: https://poly.pizza/m/5vO2YJsPEf
- Dragão CC0 Quaternius: https://poly.pizza/m/LlwD0QNUPj
- Cavalo Quaternius: https://poly.pizza/m/qvTrSG9pZF

**Situação atual**: somente rig do personagem e malhas de acessórios da versão anterior estão integrados ao Rojo; os NPCs e montarias do gameplay 0.4 ainda usam geometrias provisórias, com suporte futuro a modelos importados por `EnemyDirector`. Não declarar os novos GLBs como importados no Roblox antes dessa etapa.
