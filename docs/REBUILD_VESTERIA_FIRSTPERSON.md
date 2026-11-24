# ALNAIR — reconstrução visual local

Objetivo: reconstrução da apresentação do jogo, do menu ao cenário, combinando fantasia 3D estilizada e câmera obrigatoriamente em primeira pessoa.

Referência: código público do Vesteria (https://github.com/berezaa/vesteria) e observação visual. Adaptar direção de arte com assets de uso autorizado; não reutilizar nome, marca, mapas ou personagens exclusivos do Vesteria.

Requisitos preservados: raças humano, bruxo, morto-vivo e elfo; classes guerreiro, assassino, mago, lutador, samurai; progressão própria do Alnair.

Backup anterior: build/backups/before-vesteria-fps-redesign-20261122.

Proibição expressa: não abrir nem executar Roblox Studio neste ciclo. Todas as mudanças permanecem na pasta local.

## Atualização do modelo de personagens — 22/11/2026

- Personagens humanoides exclusivamente Roblox R6 quadradão. Modelo R15 orgânico retirado da árvore Rojo.
- src/shared/BlockyRig.lua: rig R6 nativo do Roblox (fallback de seis partes clássicas caso o carregamento falhe).
- src/shared/Appearance.lua: cabelo, rosto, orelhas, chapéus, armaduras, mantos e armas por Part/Weld; diferenças geométricas reais entre 4 raças e 5 classes.
- src/server/Bootstrap.server.luau: StarterCharacter R6, carregamento manual após seleção.
- src/server/EnemyDirector.lua: criaturas humanoides cúbicas sem importar MeshParts de personagens.
- src/client/R6Motion.client.luau: animação leve de contingência se a animação nativa estiver ausente.
- Arquivos R15/roupas antigas preservados fora de src em build/backups/blocky-r6-legacy-assets/.
- Compilação de arquivos pelo Rojo não substitui testes visuais e funcionais no Studio; proibido abrir o Studio neste ciclo.

