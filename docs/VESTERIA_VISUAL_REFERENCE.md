# Referencia visual: Vesteria -> Alnair

Repositorio estudado: https://github.com/berezaa/vesteria
Licenca do codigo do Vesteria: Apache-2.0 (versao historica, nao o jogo atual completo).

## Metodo observado

- Aparencia: src/StarterPlayer/StarterPlayerScripts/contents/coreRenderServices/appearance_manager.lua
  - Partes da roupa/acessorios organizadas por categoria e presas ao corpo do personagem.
  - Variantes de cabelo levam em conta o equipamento na cabeca.
- Camera: src/StarterPlayer/StarterPlayerScripts/contents/cameraScript.lua
  - Terceira pessoa, zoom e rotacao, tratamento de obstaculos e enquadramento da personagem.
- Movimento: src/StarterPlayer/StarterPlayerScripts/contents/animationInterface.lua
  - Camada separada de animacoes de locomocao e equipamentos, sem misturar com progressao.
- Dados: src/ReplicatedStorage/defaultCharacterAppearance.lua
  - Aparencia isolada de regras de combate e evolucao.

## Como foi adaptado no Alnair

1. O sistema de meshes 3D CC0 ja existente foi PRESERVADO. O MeshWardrobe monta camadas de visual sobre o rig R15 por partes anatomicas, agora com silhuetas mais diferentes para humano, bruxa, morto-vivo e elfo.
2. Classes mantidas: guerreiro (espada + escudo), assassino (duas adagas), mago (cajado), lutador (punhos) e samurai (katana). Peitorais, mantos, ombreiras, bracadeiras e insignias mudam de geometria entre classes, sem depender de apenas trocar cor.
3. CameraDirector continua usando a camera nativa do Roblox para preservar controles, colisao e suporte a controle/toque; adiciona enquadramento suavizado e FOV responsivo. MovementPresentation traz movimento secundario procedural, sem copiar animacoes ou IDs do Vesteria.
4. WorldLighting cria atmosfera de tarde dourada, cor e contraste, bloom muito leve, poucos raios solares e particulas raras em pontos de luz. Sem depth of field, sem filtros externos e sem loops de luz a cada frame.
5. GameRules, PlayerProgress, inventario, golpes, recompensas, quests e montarias nao foram modificados por esta adaptacao.

## Licencas

Esta implementacao usa ideias de arquitetura e observacoes do codigo do Vesteria, mas nao copia assets, animacoes ou trechos de codigo dele. O uso dos modelos 3D do Alnair segue o registro de licencas do proprio projeto.

## Limite desta etapa

Por decisao do proprietario, esta alteracao foi feita apenas nos arquivos: o Studio nao foi aberto e o jogo nao foi testado. Nenhuma raca/classe, animacao, camera ou FPS foi validada visualmente. E obrigatorio comparar todos os modelos, identificar clipping, verificar a simulacao e medir o FPS antes de afirmar conclusao ou qualidade final.
