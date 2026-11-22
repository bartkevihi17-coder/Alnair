# Alnair — Assets 3D de terceiros

Este projeto usa o corpo R15 anatomico da Quaternius no jogo. Cabelos, sobrancelhas, barba e orelhas usam malhas externas, sem Partes geometricas criadas por scripts.

## Corpo humanoide R15 - versao 0.4
- Autor de origem: Quaternius, Universal Base Characters, distribuido sob licenca CC0.
- Fonte: Superhero_Male_FullBody.fbx do pacote gratuito.
- Conversao pelo Avatar Setup do Roblox Studio: 15 MeshParts organicos, Humanoid e articulacoes para animacao.
- No repositorio: src/shared/AlnairRiggedBody.rbxmx.
- Originais e conversoes intermediarias mantidos localmente em assets/vendor/ e fora do Git.
- O jogo local exibiu o corpo organico na cena de exploracao. O editor de avatar requer verificacao visual adicional.

## Cabelos, barba e sobrancelhas
- Artista: Quaternius.
- Pacote: Universal Base Characters — https://quaternius.itch.io/universal-base-characters
- Licença indicada pelo autor: **CC0 / domínio público**.
- Origem: modelos FBX do download gratuito.
- No repositório: `src/shared/AlnairMeshes.rbxm`.

## Orelhas anatômicas
- Fonte: Innerscene, Ear Anatomy Model — https://www.innerscene.com/tools/library/3d-parts/ear-anatomy-model-6b89b9e8
- Modelo disponibilizado como CC0 / domínio público, derivado de malhas abertas do MakeHuman.
- Somente a malha externa da orelha foi extraída do arquivo GLB; o modelo da outra orelha foi espelhado geometricamente, sem esculpir um modelo novo.
- Os presets normal, pequena, alongada e élfica reutilizam essas malhas externas com diferentes escalas e rotações. A versão élfica ainda não possui uma malha pontiaguda exclusiva.
- No repositório: `src/shared/AlnairEarMeshes.rbxmx`.

## Integração e distribuição
- Arquivos binários de modelos estão incluídos em `src/shared`, carregados automaticamente pelo Rojo.
- Downloads originais e arquivos intermediários ficam em `assets/vendor/` **somente na máquina local** e não são versionados para não inflar o Git.
- O arquivo gerado `build/Alnair-v03-ear-final.rbxlx` é uma versão compilada para teste.
- Antes de publicar uma experiência no Roblox, confirme as permissões dos Mesh IDs para a conta ou grupo proprietário da experiência. Ter o asset disponível no Studio local não garante acesso no jogo publicado.
- Não inclua assets de terceiros sem verificar licença e procedência.
