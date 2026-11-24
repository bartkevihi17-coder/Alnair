# Alnair — Registro de bugs, auditoria e retestes (22/11/2026)

Este documento é a fila de correções **antes de adicionar novos capítulos**. Não marcar como validado no jogo só por compilar.

| ID | Prioridade | Área | Evidência | Status |
|---|---|---|---|---|
| AQA-001 | P0 | Cenografia | Studio: 211/216 MeshParts sem TextureContent; 216/216 mesma cor 4288914085; ambiente cinzento | Corrigido no arquivo: paleta original de 62 cores recuperada do material de GLB; retestar render |
| AQA-002 | P0 | Aparência | Avatar R15 pula roupas e armas em Appearance.apply, aplicando só cores e botas | Em correção: malhas de roupa/armas e presets por raça/classe |
| AQA-003 | P0 | Animações | NPCs importados sem Animator executando animações, T-pose dos rigs e acessórios | Em correção: movimentação, bone rigs / animações e idle; retestar no Play |
| AQA-004 | P0 | Runtime ranking | Logs do Studio AlnairGameplay:724 invalid argument #2 to insert (number expected, got string) | Corrigido local: separar duas inserções; retestar nova sessão |
| AQA-005 | P1 | Iluminação | Teste no Studio: primeiro plano praticamente preto, contraste exagerado | Em correção: melhorar ambient, outdoor, fog e pós-processamento |
| AQA-006 | P1 | Progressão | Apenas nível/itens; sem tela de atributos distribuíveis pelo jogador | Em correção: VIG, FOR, DES, INT, RES; pontos ganhos por nível |
| AQA-007 | P1 | Equipamentos | A loja melhora vida e ataque numericamente, mas armaduras não mudam visual; poucos itens | Em correção: roupa visível, defesa, botas e equipamento por slot |
| AQA-008 | P1 | Salvamento de teste | GetDataStore pode falhar em place local sem publicação | Corrigido local: guarda GetDataStore por Studio e pcall; verificar sessão |
| AQA-009 | P1 | Integração de assets | Collisions ilegais em malhas importadas; avisos no Studio Invalid mesh collision data | Corrigível: CanCollide=false e hitboxes invisíveis; confirmar contagem |
| AQA-010 | P2 | Criação de personagem | Comparar quatro raças, cinco classes, presets de rosto/orelhas/cabelo e roupa no preview | Teste guiado pendente |
| AQA-011 | P1 | Campanha | Portal 1, bloqueio portal 2/3, quests, exploração mapa/M, cripta e ilhas | Teste guiado pendente |
| AQA-012 | P1 | Combate | Ataque básico, 75 talentos, inimigos de vida própria, patrulha, rival e respawn | Teste guiado pendente |
| AQA-013 | P1 | Sandbox | Spawn, ondas, cartas de buff de run, morte e recompensa, reset run | Teste guiado pendente |
| AQA-014 | P1 | Economia/UI | Comprar, equipar, inventário I, cura H, ouro, gemas, HUD | Teste guiado pendente |
| AQA-015 | P1 | Montarias | Cavalo V Nv.2, dragão B Nv.5, voo e desmontar | Teste guiado pendente |
| AQA-016 | P1 | DEV | F8, autenticação Studio-only, nível, ouro, gemas, spawn, teleporte e buffs | Teste guiado pendente |
| AQA-017 | P2 | Publicação | Verificar ownership dos meshes, animações e texturas importados para experiência publicada | Não iniciado; exige conta/place de destino |
| AQA-018 | P2 | Desempenho | 216 malhas importadas e floresta com clones: FPS/1% low no PC alvo | Não medido |

## Validação disponível
- Compilação Luau de scripts + testes tests/run_checks.ps1;
- Auditoria XML/GLB dos assets, com cores materiais e checks de modelo;
- Roblox Studio conectado com Play habilitado, mas instâncias abertas em paralelo podem exigir autenticação novamente ao carregar outro Place;
- Para teste final usar exclusivamente build/Alnair-v05-visual-test.rbxlx e guardar logs do processo correspondente.

## Critérios de aceite
1. Nenhum erro vermelho de script no Output durante inicialização, entrada no lobby e transferência;
2. Todos os modelos no mapa com cores originais distintas e sem T-pose persistente na movimentação;
3. Raças e classes com vestimentas e silhuetas distinguíveis, preview correspondendo ao personagem;
4. Equipamento aumenta atributos reais e altera visual; compra, equipar, usar frasco e reset/teste DEV obedecem regras;
5. Testes reais de campanha, sandbox e montarias anotados individualmente antes de considerar o jogo pronto.
