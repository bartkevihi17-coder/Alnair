# Alnair - Vesteria visual replica target

OBJETIVO DO PROPRIETARIO: A primeira versao de teste deve reproduzir, tao de perto quanto os recursos e licencas permitam, a apresentacao visual do Vesteria real (nao apenas ser inspirado). DEPOIS serao feitas mudancas para a identidade Alnair.

REFERENCIAS:
- https://github.com/berezaa/vesteria (codigo Apache 2.0, reformulacao incompleta de 2020).
- Captura do menu de personagem do Vesteria: https://pbs.twimg.com/media/D5c54FQUcAAiT_Q.jpg
- Captura mundo: https://www.videogamer.com/wp-content/uploads/vesteria-codes.jpg
- Captura HUD: https://pbs.twimg.com/media/E5T0PMhXoAAaPB1.jpg

DIRETRIZES:
1. Menu igual em composicao: sobre mundo 3D visivel, coluna esquerda estreita escura, cartoes empilhados, botoes claros de selecao. Sem placa opaca de tela inteira.
2. Mundo: grama viva, arvores low-poly estilizadas, cogumelos vermelhos brancos, casas medievais de madeira e paredes claras, fogueira luminosa, caminho de pedra, barracas, flora abundante.
3. Personagens: Roblox R6 cubico obrigatorio. Vestuario em camadas, rosto, cabelo, orelhas, capacetes e silhuetas unicas; classes guerreiro, assassino, mago, lutador, samurai.
4. HUD: barras de vida/mana na parte inferior esquerda, quest log flutuante em fundo cinza escuro, icones de habilidades e consumiveis em grid a direita, informacoes compactas.
5. Camera FPS obrigatoria na exploracao e combate. Referencia Vesteria e em terceira pessoa, portanto nao pode ser idente em camera.
6. Progressao, economia, regras, raças, classes, modos e dados continuam Alnair.
7. Copiar codigo exclusivamente sob licenca permisiva seguindo avisos; nao copiar assets do jogo publicado ou imagens da database Vesteria para outro jogo sem permissao.
8. Nenhum Roblox Studio deve ser aberto ou controlado ate nova ordem.

CHECK: A implementacao anterior chamada REBORN ainda nao cumpre os itens 1-4 com fidelidade. Nao afirmar que e replica aprovada sem inspeçao de screenshots no Studio.

## Alteracoes executadas em 22/11/2026
- src/client/Alnair.client.luau: sidebar reduzida, fundo do mundo mais visivel, card empilhado com botao claro, preview R6 flutuante.
- src/client/GameplayUI.client.luau: HUD cinza-carvao, HP vermelho e mana azul apenas quando existe estado numerico, quest tracker direito e grade de icones na direita.
- src/server/World.lua: bosques com cogumelos gigantes vermelhos de pintas brancas, tres barracas novas e mundo de vila mais vivo.
- src/client/CameraDirector.lua: camera de menu proxima a vila (continuam primeira pessoa e R6 no jogo).
- src/shared/Appearance.lua e src/shared/Catalog.lua: chapeu de cogumelo opcional e tunica verde para o personagem quadrado.

Checagem: 15 criterios estruturais passaram e rojo build concluiu para build/Alnair-vesteria-visual-test-R6.rbxl.
Nao foi aberto Roblox Studio; testes de visual, jogabilidade, FPS e fidelidade ao Vesteria nao foram executados.
Esta etapa aproxima layout e direcao de arte da referencia mas NAO e copia 1:1 dos modelos, mapas ou interface proprietaria.
