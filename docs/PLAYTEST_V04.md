# ALNAIR 0.4 — Como testar no Roblox Studio

## Abrir protótipo
No Windows: `C:\Users\bartk\Desktop\Alnair\build\Alnair-v04-playtest.rbxlx` (gera novamente com `ABRIR-ALNAIR.cmd` ou Rojo). Abra o Studio já autenticado e clique em **Jogar**. Se o Studio pedir nova autenticação, conclua o login na sua conta antes de tentar testar. O arquivo compilado não substitui a experiência publicada.

## Teclas e atalhos
| Entrada | Ação |
|---|---|
| WASD | Andar / mover montaria |
| Mouse | Câmera em terceira pessoa e ataque básico (clique esquerdo) |
| Shift | Corrida |
| M | Mapa com neblina de guerra |
| I | Inventário personalizado |
| K | Livro de talentos |
| 1 até 5 | Executar habilidades escolhidas |
| H | Consumir Frasco Rubro |
| V | Montar/desmontar cavalo (nível 2) |
| B | Montar/desmontar dragão (nível 5) |
| Espaço / Ctrl | Subir / descer voando montado no dragão |
| F8 | Janela DEV (também disponível por botão no menu inicial) |

## Roteiro de validação manual
1. Inicie com **Campanha**; conclua criação e introdução e confirme a chegada ao **Nexo das Estrelas** (lobby).
2. Observe os portais **Mapa 1** (aberto), **Mapa 2/3** (fechados), Arena e ranking.
3. Use o portal do mapa 1 e teste a câmera, a movimentação, o fogo de quest, as criaturas em patrulha e a abertura do mapa `M`.
4. Use o botão **DEV**, digite a senha definida para o teste, defina nível 3 e escolha 1 habilidade. Confirme que os outros dois talentos desaparecem da lista de aquisição.
5. Teste níveis 5, 7, 9 e 11, o limite de 5 talentos, ataques com 1–5, ouro, gemas e equipamento no inventário.
6. Teste cavalo no nível 2 e dragão no nível 5, incluindo voar e descer em uma ilha suspensa.
7. Explore a Cripta Afogada, derrote o Vigia sem Sol, verifique a quest seguinte e o Farol Astral.
8. Volte ao lobby, visite o mercador e compre uma espada / armadura com ouro de DEV; equipe e veja o efeito nos atributos.
9. Acesse **Sandbox**, derrote uma horda, escolha uma das três cartas, prossiga para outra. Ao morrer, confira o resumo de ouro/XP e o recorde.
10. Compare um inimigo após perder para ele: a marca de rivalidade deve elevar sua dificuldade. Concluir os testes sem erros fatais no Output.

## Testes automatizados disponíveis
Na pasta do projeto, execute:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\run_rules.ps1
```
O teste Luau verifica 75 habilidades, progressão XP, desbloqueios de montarias, 5 quests e 12 cartas. Todos os scripts também podem ser validados com `luau-compile.exe --null <arquivo>` e a experiência gerada por `rojo.exe build default.project.json -o build\Alnair-v04-playtest.rbxlx`.

## Advertências
- Em **Studio**, o perfil de testes não é persistido. Em jogos publicados, o DataStore exige permissões e testes com a conta correta.
- O botão DEV é **desabilitado no servidor** fora do Roblox Studio. Nunca publique a senha de desenvolvimento em scripts do cliente.
- Nem todos os modelos externos já estão dentro do arquivo Roblox. Eles estão na pasta local para importação e precisam de ajustes de rig/animações e verificação de propriedade dos MeshIds.
- A classificação do ranking é um protótipo, e os portais 2/3 não têm mapas prontos. Multiplayer PvP/co-op e compra real de gemas estão desabilitados.
- Não habilite pagamentos reais até configurar os IDs válidos e ProcessReceipt com idempotência, registro e tratamento de falhas.
