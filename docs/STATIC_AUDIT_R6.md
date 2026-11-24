# Alnair — revisão local R6 e primeira pessoa

## Escopo
- Foco: personagens quadrados clássicos do Roblox (R6), menu de criação e jogo, inimigos humanoides blocky, interface e câmera em primeira pessoa.
- Proibido abrir/operar o Roblox Studio neste ciclo; nenhuma imagem de prévia, animação, jogo real ou medição de FPS foi produzida.
- Ponto de recuperação: build/backups/before-vesteria-fps-redesign-20261122
- Código legado R15 retirado da árvore src e guardado em build/backups/blocky-r6-legacy-assets.

## Arquivos fundamentais
- src/shared/BlockyRig.lua: rig nativo R6 do Roblox; seis Parts e Motor6Ds no fallback
- src/shared/Appearance.lua: vestes e geometrias procedurais por raça/classe com acessórios presos às partes
- src/server/Bootstrap.server.luau: StarterCharacter R6, carregamento manual após o menu
- src/server/EnemyDirector.lua: inimigos de corpo cúbico e sem importar corpos humanoides
- src/client/Alnair.client.luau: novo menu e prévia de boneco quadrado
- src/client/CameraDirector.lua: primeira pessoa durante exploração, visão de armas e mãos da raça
- src/client/R6Motion.client.luau: animação leve alternativa se Animate padrão não estiver presente
- src/client/GameplayUI.client.luau: cores de fantasia, mira e liberação do cursor nos modais
- src/server/World.lua, WorldExpansion.lua, WorldLighting.lua: ambientes coloridos com pós-processamento econômico

## Identidade própria
- Humano, bruxa, morto-vivo, elfo usam o mesmo esqueleto R6 com silhuetas alteradas por acessórios, roupas e detalhes de cabeça.
- Guerreiro usa espada/escudo; assassino duas adagas; mago cajado; lutador duas manoplas; samurai katana.
- Não copiar assets ou interfaces proprietárias do Vesteria; usar referências de gênero e a biblioteca de cenário CC0 local.
- Regras de nível, XP, moedas, compras e quests são as do Alnair, não as do Vesteria.

## Estado de validação
- Rojo build gerado localmente em build/Alnair-reborn-R6.rbxl (compilação da árvore, não execução do jogo).
- PENDENTE: conferir spawn R6 e Animator, rosto/acessórios e classes lado a lado, FPS e clipping, RPCs, portais, loja, missões, horda e reaparecimento.
- Não marcar como concluído ou validado visualmente antes de realizar Play e screenshots no Roblox Studio com autorização expressa.
