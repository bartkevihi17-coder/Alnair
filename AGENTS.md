# AGENTS.md — Regras obrigatórias do projeto Alnair

Estas são instruções permanentes do repositório para qualquer agente ou colaborador. Valem em TODAS as próximas alterações e revisões do jogo Roblox Alnair. A conversa do proprietário em 22/11/2026 é a origem deste documento; a decisão posterior de usar R6 clássico prevalece sobre instruções mais antigas.

## 0. Sessão Roblox Studio
- **Reutilizar sempre a instância do Roblox Studio já aberta no desktop.** Nunca abrir uma segunda instância, outro processo ou tentar executar um novo Place com duplo clique / pc_open sem autorização.
- Focar a janela existente via gerenciador de janelas. Para atualizar o código, privilegiar o Rojo Live Sync ligado ao Studio aberto, ou usar recursos internos do próprio Studio, preservando a sessão/autenticação.
- Se a sincronização com o Place aberto for impossível, explicar o bloqueio; não solucionar abrindo outras instâncias.
- Antes de testes destrutivos, guardar cópia da experiência e proteger as alterações do usuário no Studio.
- Nenhum login novo deve ser disparado por abrir outra instância.

## 0.5. Meta visual temporaria: replicar Vesteria
- A nova orientacao do proprietario substitui o pedido anterior de mera inspiracao. A primeira build de teste deve buscar fidelidade maxima a apresentacao visual de Vesteria, especialmente menu de selecao em coluna lateral estreita, mundo de fantasia vivo, aparencia das roupas, proporcoes, caminhos, construcoes, fungos, cores e HUD.
- O resultado ainda preserva as excecoes expressas do usuario: todos os personagens humanoides usam R6 quadradao e a exploracao e em primeira pessoa. Progressao, classes, combate, modos e dados sao originais de Alnair.
- A fonte publica berezaa/vesteria e uma reformulacao incompleta. Nao contem todos os modelos/mapas/UI do jogo publicado. Usar recursos com licenca e criar substitutos em estilo correspondente sem reutilizar assets proprietarios da experiencia publicada ou marcas de Vesteria.
- O proprio usuario fara os testes: nao abrir Roblox Studio sem autorizacao nova, e nao afirmar similaridade visual 1:1 ou funcionamento validado sem confronto real das capturas.

## 1. Quatro raças, cinco classes e base R6 obrigatória
- **Apenas o boneco quadrado clássico do Roblox (R6)** pode ser utilizado para jogadores e personagens humanoides. Não usar modelos humanos importados, corpos orgânicos R15, FBX ou malhas 3D externas para o corpo. A decisão mais recente do proprietário substitui a regra anterior de corpos 3D próprios para cada raça.
- **Manter as quatro raças**: humano, bruxa, morto-vivo e elfo. Todas compartilham a base R6, mas têm rosto, cabelo, orelhas, silhuetas de acessórios, vestes e adornos genuinamente diferentes. Só trocar a cor não é suficiente.
- **Manter as cinco classes**: guerreiro (espada+escudo), assassino (duas adagas), mago (cajado), lutador (punhos) e samurai (katana). Devem ter equipamentos e roupa específicos; todo personagem deve estar vestido, inclusive quando escolher a opção de roupa simples.
- Utilizar cabelo, barba, armaduras, mantos, chapéus e armas construídos com partes Roblox comuns e soldas, ou acessórios licenciados. Não depender de novos assets de corpo humanoide externos.
- NPCs humanoides e inimigos também devem manter visual blocky. Animais, dragões, construções, rochas e vegetação podem usar modelos 3D de cenário licenciados.
- Primeira pessoa obrigatória na exploração e combate; a prévia do criador e as cutscenes podem usar câmera externa para mostrar o vestuário.
- **Neste ciclo trabalhar apenas nos arquivos locais:** não abrir, controlar nem iniciar Roblox Studio sem nova autorização expressa.

## 2. Critérios de validação
- Antes de afirmar que ficou pronto, testar **dentro do jogo** e fazer **capturas individuais das quatro raças e cinco classes**; comparar silhueta, acessórios, roupas e animações lado a lado.
- Se dois personagens parecerem iguais ou muito parecidos, tratar como falha a corrigir.
- Validar tela de seleção E personagem real no Play, inclusive câmera, transições e equipamentos.
- Falhas de performance, cinza sem material, T-pose, malha sem textura/cores e erros de Output são bloqueantes.
- Compilação Luau, testes estáticos e arquivos gerados não substituem validação visual e jogabilidade real.

## 3. Câmera e detalhes
- Implementar exatamente os parâmetros pedidos: ângulo, distância, tipo RPG, rotação, zoom e estilo. Testar os controles no Play.
- Não trocar pedidos específicos por soluções genéricas, e não disfarçar alternativas incompletas como solução.
- Se ferramenta, asset, rig ou sessão impede execução fiel, declarar a limitação e sugerir alternativa.

## 4. Escopo literal
- Não omitir, renomear, simplificar ou substituir as raças, classes, nomes, características, equipamentos e funcionalidades especificados pelo proprietário sem avisar.
- Preservar mecânicas existentes e evitar regressão. Neste ciclo, **corrigir bugs e estabilizar antes de criar funcionalidades supérfluas**.

## 5. Transparência e qualidade
- Ao concluir cada etapa, informar separadamente: **Implementado / Testado no Studio / Pendente / Limitações**.
- Nada pode receber status 'validado visualmente' antes das screenshots reais correspondentes.
- Manter o registro de testes e bugs em docs/QA_LEDGER.md, incluindo evidência, causa, correção, resultado de reteste e data.
- Criar commits rastreáveis no repositório GitHub Alnair, sem dizer que foram enviados ao GitHub se estiverem apenas locais.

## 6. Critérios funcionais
- Confirmar campanha (quests/portais/mapa), sandbox (ondas/cartas/recompensa), inventário/economia, habilidades por nível, atributos, loja/equipamentos, inimigos, animações e montarias em testes reais.
- Não expor senhas de dev em produção. Modo DEV exclusivo para ambiente Studio até definição de autenticação robusta.
- Verificar permissões das malhas/texturas/animações na experiência publicada, não apenas no ambiente de desenvolvimento.

**Regra final:** a aprovação da arte exige R6 clássico com trajes e acessórios diferentes de verdade, não só troca de cores; a aprovação do código exige teste real no Roblox Studio; e a instância já aberta deve ser reutilizada.
