# Alnair — auditoria geral, correções e bloqueios de lançamento
Data: 23/11/2026
Ambiente: VPS privado /opt/alnair-visual-lab
Estado: **OFFLINE QA PASS / NOT RELEASE READY**

## Escopo
Executar a maior avaliação possível sem acesso ao motor Roblox no servidor e sem modificar o computador do usuário. Verificar código, módulos reais com Lune, dados, economia, equipamento, progressão, IA, input mobile/gamepad, interações, UI em várias resoluções, modelos 3D, iluminação, sombra, céu, animações R6, transição cinematográfica, colisões pretendidas, draw calls, empacotamento do arquivo Roblox e regressões. Ao encontrar defeito, corrigir e repetir os testes. Não confundir aparência da prévia web com motor Roblox.

## Correções aplicadas ao código REAL do Roblox
1. **Mundo sem colisões** — ArtAssets.prepare desabilitava colisão de todas as casas, fortificações, paredes, pedras e construções. Ajustado para colisão seletiva em estruturas e troncos proxy invisíveis para árvores; folhas não bloqueiam movimento. Ainda requer Play para conferir portas e travessias.
2. **Ataques atravessando paredes** — o servidor aplicava dano somente por distância/direção; agora EnemyDirector usa Workspace:Raycast excluindo lutadores e checando obstáculos. Ajustado cone de ataque e checagem também para golpes de inimigos. Precisa testar comportamento de IA e pathfinding ao vivo.
3. **Corrida não autoritativa** — cliente forçava WalkSpeed local, podendo conflitar com equipamentos, atributos, montarias e arena. Agora o cliente solicita sprint via RemoteEvent e o servidor valida boolean, modo, montaria, personagem e limite de chamadas. FOV permanece local, bônus de velocidade preservados.
4. **Combate touchscreen e gamepad incompletos** — botões ATACAR e FRASCO no celular e ButtonR2/ButtonL1 no controle. Ocultos durante menus e modais. Inputs enviam eventos reais de combate, não placeholders.
5. **HUD mentindo sobre estado** — sem atualização imediata após dano, mana vazia mesmo inexistente e moeda premium desnecessária. Barras reagem a Humanoid.HealthChanged/MaxHealth; mana só aparece se maxMana > 0 e gemas somente quando possuídas.
6. **Interface de desenvolvimento fora de hora** — botão DEV oculto fora de gameplay no Roblox Studio e F8 restrito a Studio.
7. **Modais e HUD comprimidos no celular** — layouts responsivos, janelas modais com tamanho adaptativo.
8. **Sala do menu aberta ao céu** — MenuHouseStage passou a gerar teto, vigas e parede frontal com vão de porta baseados nas medidas reais do prefab, além de piso e paredes escalados por GetBoundingBox.
9. **Parser Luau ausente** — acrescentado compilador oficial, falhando o pipeline se um LocalScript, Script ou ModuleScript tiver erro de sintaxe.

## Correções da PRÉVIA 3D do laboratório (não são o renderizador Roblox)
10. **Renderização excessiva** — mais de 1.000 draw calls por imagem devido a GLB repetidos. Refatorado para THREE.InstancedMesh com lotes espaciais de 85 unidades; testes mediram 1.338→301 desktop e 1.063→233 mobile. Os milissegundos medidos em software rasterizer não são FPS do jogo.
11. **Personagem desaparecia ao trocar raça/classe** — clone herdava visible=false do avatar do mundo. Agora a visibilidade é explícita e a captura espera pelo render completo. Teste só passa se o corpo existir em pixels, não apenas se hashes diferirem.
12. **Raças/classes pouco distintas** — detalhes extras de armadura, escudo, capuz, adagas, cajado, manoplas e kabuto no preview R6. Mantido o rig tradicional do Roblox no jogo.
13. **Seleção mobile sem personagem / sobreposição nas opções** — área de herói restaurada em portrait, com testes objetivos de interseção entre retângulos de UI e controles.
14. **Interior sem teto no navegador** — teto, vigas, fachada e abertura de porta completos, sem usar imagem plana como fundo.
15. **Gameplay do preview mostrava mana e missão inventadas** — substituído por primeiro objetivo verdadeiro, HP ilustrativo coerente com as regras, frasco/ataque demonstrativos. A prévia NÃO executa combate real.

## Resultados verificados
- 306 asserts de GameRules e Catalog.
- 825 asserts do módulo PlayerProgress real em 15 perfis isolados, cobrindo XP, inventário, compra, equip, atributos, talentos, poção, missões, rivais e exploração.
- 5.195 asserts do módulo R6MotionMath real.
- 41 auditorias estáticas existentes, 31 auditorias 3D/cinemática, 30 de R6 e 56 gates finais.
- 6 cenários de layout responsivo; 9 capturas R6 FPS; 9 capturas de raça/classe com verificação pixel + diferença de silhueta; 6 capturas gerais.
- 9 casas / 156 módulos de parede medidos no browser sem abertura nos cantos pela AABB.
- Animação browser: câmera até casa, porta abrindo, seleção de raça, classes e retorno.
- Perfil gráfico browser: 301 draw calls desktop e 233 mobile no Chromium software; limites definidos 420/350.
- Compilação de **todos os scripts pelo compilador oficial Luau** passou.
- Rojo gerou o arquivo Alnair-visual-lab-server.rbxl e o equivalente XML.
- XML .rbxlx inspecionado: 20 scripts classificados corretamente, 216 MeshParts, 1.529 objetos.
- Testes unificados: /opt/alnair-visual-lab/run_all.sh → PASS offline.

## Pendências/BLOQUEIOS (não suavizar)
1. **Roblox Studio/Play e teste visual real pendentes:** o conector para o desktop está offline. FPS real, câmera de corpo inteiro, clipping, animação, UI e iluminação ainda não foram vistos em Play.
2. **DataStore real e replicação em multiplayer:** testamos regras e perfis isolados; não testamos gravação na infraestrutura Roblox, nem sincronização de animações Motor6D/combate entre jogadores.
3. **Cooperativo e multijogador:** menu é propositalmente não funcional e sinalizado "Em desenvolvimento"; não inventar sucesso.
4. **Áudio:** o jogo real ainda não possui trilha/sons implementados; usar apenas áudios grátis/licenciados caso sejam adicionados.
5. **IA e colisões físicas:** ataques atrás de paredes bloqueados em código, mas rotas em torno de obstáculos, portas, montarias e interações exigem validação do motor.
6. **Nova biblioteca GLB Kenney:** esta biblioteca ainda aparece apenas na prévia Three.js; o build Roblox conserva os 216 MeshParts já existentes em AlnairArtV05. Importar esses GLBs requer trabalho com o motor/asset pipeline.
7. **Primeira pessoa R6 olhando para baixo:** mesmo com câmera suavizada, a prévia mostra o torso ocupando demais em algumas posições. Só aprovar a solução depois de capturas diretas do Roblox com pessoas jogando.
8. **Robustez de longo prazo:** não há simulação completa de sessões reais de hora, falhas de rede, FPS físico, DataStore em produção ou usuários simultâneos.

## Regra de decisão
**OFFLINE_QA_PASS não significa jogo pronto. Estado = NOT_RELEASE_READY.**
Não publicar como versão final enquanto testes dentro do Roblox não comprovarem visual, física, FPS, salvamento, ausência de erros no Output, combate e integridade das animações nas plataformas suportadas. Retomar os testes no motor quando a máquina autorizada estiver disponível; não criar uma instância desnecessária do Roblox Studio, reutilizar a existente.

## Evidências
- /opt/alnair-visual-lab/artifacts/full-audit-report.json
- /opt/alnair-visual-lab/artifacts/last-run.log
- /opt/alnair-visual-lab/artifacts/compiled-place-report.json
- /opt/alnair-visual-lab/artifacts/render-budget.json
- /opt/alnair-visual-lab/artifacts/character-pixel-report.json
- /opt/alnair-visual-lab/artifacts/character-matrix.json
- /opt/alnair-visual-lab/artifacts/visual-layout-report.json
- /opt/alnair-visual-lab/artifacts/r6-source-audit.json
- /opt/alnair-visual-lab/artifacts/assembly-report.json
- /opt/alnair-visual-lab/artifacts/cinematic-report.json

Nenhum equipamento do usuário foi modificado, nenhum deploy corporativo ou publicação no GitHub/Roblox foi feito nesta etapa. Sem Blender, sem software ou asset pago.
