# Alnair - trajes detalhados e camera RMB
Data: 23/11/2026. Nao publicar sem QA real no motor.

## Controles
- Gameplay: botao direito pressionado gira camera de terceira pessoa (180 graus totais, +/-90 graus desde o rumo inicial), sem inverter o eixo vertical.
- Gameplay: botao esquerdo permanece ataque basico.
- Criacao de raca, classe e visual: botao esquerdo pressionado arrasta avatar; sem rotacao automatica e o angulo permanece apos soltar.
- Primeira pessoa temporariamente desativada.

## Cosmeticos
- Avatar R15 BLOCKY autentico da Roblox com juntas articuladas e HumanoidDescription.
- Cinco BackAccessories autenticos, diferentes, por personagem e NPC. Todos 0 Robux, criador Roblox, tipo 46 e testados no Studio em 23/11/2026:
  Dog Backpack 98752422639730, Green Block 117627132830661, Red Block 115223868209681,
  Knowledge Aura 100061531345826, Yellow Block 106228206889859, Silver Block 71409823493730.
- ShoulderAccessory Starwisp 119934643965525, gratuito, tipo 44, criador Roblox.
- Roupas classicas + cabelo + chapéu + armas do Creator Store. As listas variam por classe.
- Apos adicionar 5 BackAccessories, distribuir os slots via AccessoryWeld e reduzir apenas os MeshParts originais exagerados. Nao construir novos modelos de corpo/armadura.
- 5 armas gratuitas do Creator Store reais e sem scripts de terceiros: espada, escudo, adaga, cajado, katana (src/assets/AlnairWeapons.rbxm).
- Sem efeitos mecanicos de armadura nesta fase: apenas vestuario experimental.

## Performance
- StreamingEnabled verdadeiro, StreamingTargetRadius=160, menu e vila prioritarios.
- Objetos distantes gerados em lotes, sem perder colisao das estruturas.
- LightingStyle=Realistic, cor/exposicao calibradas, sombras mantidas.
- Medicao de memoria no Studio nao equivale a FPS em dispositivo real.

## QA
- Mercado oficial confirmado por MarketplaceService dentro do Studio.
- Teste nativo R15 gerou cinco BackAccessories + Starwisp simultaneamente.
- tests/qa_official_costumes.luau: 267 verificacoes para 20 combinacoes.
- Sintaxe de todos os arquivos Luau validada.
- Posicionamento final dos novos acessorios e camera RMB ainda precisam ser vistos e testados em Play. Nao declarar visual completo antes dessa revisao.

Regra permanente: reutilizar a sessao existente do Roblox Studio, nao abrir outro Studio.
