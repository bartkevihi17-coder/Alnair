# ALNAIR — Registro de qualidade e correções (22/11/2026)

Este arquivo é a fonte de verdade dos defeitos vistos no Roblox Studio. Atualizar ao corrigir e retestar; não marcar resolvido apenas por compilar.

## Critérios de validação
- **Código:** compilar todos os scripts Luau, rodar testes de regras e validar arquivo Rojo.
- **Visual:** conferir em jogo, não apenas no importador.
- **Gameplay:** entrada no menu, raças, classes, criação, lobby, portais, combate, vitória/derrota, lojas, equipamento, atributos, montarias, missões, inventário, arena e persistência.
- **Compatibilidade:** multiplayer e DataStore após publicar ainda exigem teste real (não podem ser homologados em place local).

## Bugs e pendências encontradas
| ID | Severidade | Componente | Evidência | Status |
|---|---|---|---|---|
| QA-001 | Alta | Assets do mundo | Importador deixou cores cinza/branco em dezenas de MeshParts | Corrigindo/retestar |
| QA-002 | Alta | Previews de raça/classe | Personagens aparecem com braços em T-pose | Em correção |
| QA-003 | Alta | NPCs | Esqueleto em T-pose, animação dos modelos 3D não ligada à IA | Em correção |
| QA-004 | Alta | Classes | Aparência varia principalmente a cor, sem trajes característicos | Em correção |
| QA-005 | Alta | Equipamentos | Armadura soma vida mas não possui redução física efetiva | Em correção |
| QA-006 | Alta | Progressão | Não existe interface para investir pontos em atributos | Em correção |
| QA-007 | Média | Loja/inventário | Compra/equipar já existem; visuais não são atualizados ao equipar | Em correção |
| QA-008 | Alta | Studio offline | DataStore sem place publicado bloqueava progresso | Corrigido no código; validado em partida local |
| QA-009 | Média | Ranking | table.insert com três argumentos usava string como índice | Corrigido no código; retestar |
| QA-010 | Média | Modelos de montaria | Cavalo/dragão importados sem cor e animação adequada | Em correção |
| QA-011 | Média | Arena | Jogabilidade completa e recompensas ainda não passaram por roteiro de regressão | Pendente |
| QA-012 | Média | Combate | Danos, bloqueios, habilidades, XP e morte ainda não foram verificados integralmente | Pendente |
| QA-013 | Média | Missões/portais | Testar as cinco missões e trajetos de ida/volta | Pendente |
| QA-014 | Média | Câmera/UI | Escalas, orientação, rolagem e interações em diferentes resoluções | Pendente |
| QA-015 | Alta | Publicação | Testar sincronização de dados, pagamentos e multiplayer em ambiente publicado | Bloqueado: requer place publicado |
| QA-016 | Média | Asset de Bruxa | Modelo importado tem aparência de pequeno demônio, não de maga/bruxa | Pendente: achar substituto adequado |
| QA-017 | Média | Texturas remotas | Alguns IDs do Roblox dão 401/403 no Studio por autenticação/acesso | Pendente: diferenciar erro de login vs ID restrito |

## Testes que já foram feitos
- [x] A compilação Luau e os testes de regras retornaram PASS.
- [x] Rojo construiu o projeto com 72 prefabs gratuitos e 216 MeshParts.
- [x] Studio abriu menu principal e seleção de raças/classes.
- [x] A campanha entrou no lobby e mapa; foi possível aumentar o nível via DEV.
- [x] Um esqueleto importado apareceu na cena com nome/vida.
- [x] A montaria cavalo apareceu ao pressionar V.
- [ ] Retestar todas as áreas acima após mudanças finais (visual e comportamento).
- [ ] Auditar as ações de todos os botões e a loja.
- [ ] Medir FPS/contagem de instâncias e observar erros após 5 min de jogo.
- [ ] Testar com conta/ambiente publicado, sem modo DEV.

## Política de correção
Manter comportamento anterior quando ainda não foi substituído com sucesso. Não remover hitboxes, missões ou dados persistidos. Guardar backups no Git e no diretório build/backups. Registrar aqui novas falhas e limitações.
