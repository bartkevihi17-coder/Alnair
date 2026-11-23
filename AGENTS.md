# AGENTS.md — Regras obrigatórias do projeto Alnair

Estas são instruções permanentes do repositório para qualquer agente ou colaborador. Valem em TODAS as próximas alterações e revisões do jogo Roblox Alnair. A conversa do proprietário em 22/11/2026 é a origem deste documento.

## 0. Sessão Roblox Studio
- **Reutilizar sempre a instância do Roblox Studio já aberta no desktop.** Nunca abrir uma segunda instância, outro processo ou tentar executar um novo Place com duplo clique / pc_open sem autorização.
- Focar a janela existente via gerenciador de janelas. Para atualizar o código, privilegiar o Rojo Live Sync ligado ao Studio aberto, ou usar recursos internos do próprio Studio, preservando a sessão/autenticação.
- Se a sincronização com o Place aberto for impossível, explicar o bloqueio; não solucionar abrindo outras instâncias.
- Antes de testes destrutivos, guardar cópia da experiência e proteger as alterações do usuário no Studio.
- Nenhum login novo deve ser disparado por abrir outra instância.

## 1. Quatro raças e cinco classes: modelos realmente diferentes
- Raças obrigatórias e sem substituições: **humano, bruxo, morto-vivo e elfo**.
- Cada raça deve ter **modelo 3D próprio e silhueta reconhecível**, com proporções, rosto, cabelo, orelhas, pele e acessórios diferentes. Apenas variar a cor **não conta**. Mesmo corpo base com variação de tinta **não satisfaz** esta regra.
- Classes obrigatórias: **guerreiro (espada+escudo), assassino (duas adagas), mago (cajado), lutador (punhos) e samurai (katana)**.
- Classes com roupas, armaduras, armas e acessórios visivelmente distintos. Todo personagem deve estar vestido; proibir corpos nus ou avatares padrão sem roupa.
- Preferência por modelos 3D gratuitos com licenças comprovadas, importados, rigados, animados e testados no Roblox Studio. Registrar origem, licença e permissões dos assets.

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

**Regra final:** a aprovação da arte exige modelos 3D diferentes de verdade, não troca de cores; a aprovação do código exige teste real no Roblox Studio; e a instância já aberta deve ser reutilizada.
