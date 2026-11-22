# ALNAIR — Documento de jogo 0.4

## Premissa: A Queda das Sete Estrelas
Alnair era a estrela guia de sete reinos. Quando seu brilho se partiu, a memória da terra começou a se desfazer: os mortos retornaram sem sepultura, montanhas emergiram nas fronteiras e cidades inteiras ficaram suspensas sobre o mundo. Os jogadores são **Portadores da Centelha**, viajantes capazes de reacender os fogos antigos. Cada brasa restabelecida revela caminhos, áreas e informações sobre o desaparecimento das estrelas.

O **Cronista Astral**, presente no lobby chamado **Nexo das Estrelas**, narra a queda dos reinos. O primeiro capítulo, **Vale das Cinzas**, é aberto; os mapas II e III permanecem bloqueados. Os jogadores compartilham o Nexo antes de partir. O ranking ordenado mostra níveis e inimigos eliminados, com atualização conforme salvamentos.

## Estrutura de campanha

| Etapa | Missão | Local | Recompensa |
|---|---|---|---|
| 1 | A Centelha na Pedra: acender o Braseiro Primordial | Praça do Primeiro Fogo | 60 ouro + 60 XP |
| 2 | Ossos que se Levantam: eliminar 3 esqueletos | Vale das Cinzas | 90 ouro + 95 XP |
| 3 | Sussurros da Cripta: descer à Cripta Afogada | Ruínas do vale | 110 ouro + 120 XP |
| 4 | O Vigia sem Sol: vencer o capitão | Cripta Afogada | 160 ouro + 170 XP |
| 5 | A Escada do Céu: acender o Farol Astral | Ilhas do Éter | 260 ouro + 240 XP |

Os monstros têm níveis diferentes, distribuídos pelo mundo. É possível sair da rota, mas áreas distantes contêm inimigos com mais vida e dano. O mapa é aberto com **M** e possui células descobertas conforme o personagem explora, sem revelar tudo de uma vez. As bordas usam montanhas de pedra; trilhas acessíveis levam a alguns picos; existem ilhas suspensas e uma cripta subterrânea. O mundo inicial é um **blockout procedural** para testar navegação, não o cenário artístico definitivo.

## Progressão
Níveis oferecem vida e dano adicionais. Nos níveis **3, 5, 7, 9 e 11**, a classe escolhida recebe **3 talentos exclusivos** e deve selecionar somente **1**. Os outros dois ficam descartados para aquele personagem. São **5 habilidades regulares no máximo**. Existem cinco classes com 15 opções cada: Guerreiro, Assassino, Mago, Lutador e Samurai. Escolhas persistem no perfil após salvamento em ambiente publicado; o Studio usa dados temporários.

Montarias: **cavalo no nível 2** e **dragão voador no nível 5**. A primeira usa velocidade terrestre; a segunda possui movimentação tridimensional por teclado. Os modelos de montaria usados no protótipo ainda são formas geométricas, enquanto os modelos 3D encontrados aguardam a importação final.

## Sandbox: Arena do Crepúsculo
O modo sandbox não usa o mundo aberto. Ele move o jogador para **uma arena isolada**. Cada horda aumenta quantidade, atributos e variedade dos inimigos. Após vencer uma onda, três cartas aleatórias oferecem buffs temporários, que se acumulam somente durante aquela run: dano, defesa, velocidade, vida, cura, roubo de vida, ouro, XP e recarga. A onda seguinte só começa depois de uma carta escolhida. **Ao morrer**, ouro e XP acumulados são pagos, e o recorde de horda é atualizado. **Ao desistir**, a run é encerrada sem o pagamento; isso é intencional no protótipo. Não são concedidas gemas na arena.

## Economia
- **Ouro**: obtido de inimigos, missões e baús; gasto em frascos, espadas e armaduras no mercador do Nexo.
- **Gemas**: moeda premium **não dropa**. A venda real está desabilitada até a criação e configuração de produtos oficiais no Roblox. O modo DEV pode adicionar ou remover gemas para testes.
- Preços, danos, limites, níveis e recompensas são definidos **no servidor**. Os clientes enviam apenas ações. O inventário é próprio, sem a mochila padrão como interface principal.
- Os equipamentos comprados e equipados modificam ataque ou vida, em vez de serem apenas itens decorativos.

## Inimigos
Esqueletos, orcs, bruxas, dracos e o Vigia sem Sol aparecem em regiões e dificuldades diferentes. O protótipo contém patrulha, perseguição, ataques, tentativa de retirada e movimentos procedurais de braços, pernas e asas. A marca da criatura que derrotou um jogador é lembrada. Num reencontro, o rival é fortalecido e, se derrotado, concede um selo especial. Isso é uma **primeira versão de sistema de rivalidade** — ainda não inclui uma rede completa de capitães, diálogos procedurais ou facções.

## Modo desenvolvedor
Um botão discreto **DEV** fica no menu inicial; **F8** abre a oficina. A senha temporária está no **script do servidor**, e o acesso é aceito **somente durante testes no Roblox Studio**. Comandos permitem definir nível, adicionar ou retirar ouro e gemas, conceder XP, aprender/resetar habilidades, alterar missão, revelar/ocultar mapa, avançar ondas, gerar inimigos, curar, desbloquear portais e teleportar entre áreas. Antes de qualquer lançamento público, remover a senha hardcoded e substituí-la por autorização por UserId/grupo com auditoria.

## Referências de linguagem de jogo
- **Sombras de Mordor**: inimigos que patrulham, perseguem e recordam encontros com o jogador — inspiração mecânica, sem copiar personagens ou código.
- **Elden Ring**: inventário mais sóbrio, exploração por risco, criptas, áreas de difícil acesso e recompensas por descoberta.
- **Paladins**: distinção entre habilidades de classes, avanço progressivo e leitura clara dos efeitos.
O jogo tem nome, ambientação, personagens e arte próprios.

## Estado do protótipo e limitações
Os scripts e regras compilam, mas ainda falta completar testes integrados de execução no Roblox Studio. Montarias e inimigos ainda usam malhas substitutas; modelos GLB gratuitos foram baixados para a pasta local `assets/vendor/Enemies`, mas sua importação no Roblox ainda exige conferir materiais, rig, animações e permissões dos novos IDs. Multiplayer foi desenhado como Nexo social compartilhado; criação de servidores/places separados para cada mapa ficará para uma fase posterior. Modo co-op e PvP continuam indisponíveis. O mundo tem geometria procedural de protótipo, não terreno final esculpido com Terrain.
