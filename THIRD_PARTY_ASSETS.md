# Alnair — Assets 3D de terceiros

Este projeto conserva o corpo base clássico do Roblox (R6/blocky). Os acessórios de cabelo, sobrancelhas, barba e orelhas usam **malhas importadas**, não blocos gerados por scripts.

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
