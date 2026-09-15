# Assets — primeira fase jogável

Há 35 imagens da direção pixelada no manifesto: 30 integradas à versão 0.1.0 e cinco bases de referência visual. As versões anteriores continuam preservadas como histórico.

[Galeria animada](../production/GALERIA.html) · [Procedência e prompts](../production/README.md) · [Manifesto](manifest.json)

Cada pasta `characters/<personagem>` contém `idle-pixel-v1.png`, `walk-pixel-v1.png`, `run-pixel-v1.png`, `jump_cycle-pixel-v1.png` e `celebrate-pixel-v1.png`. São PNGs transparentes, com 30 quadros por personagem. Samara está com o look Nude Project, sem vestido.

As cópias usadas pelo jogo ficam em `game/art`, com índice de atlas em `animations.json`. Os PNGs não foram modificados para recorte; o motor recorta as regiões ao renderizar e alinha os pés. `game_ready: true` identifica os 30 originais já integrados e testados. Isso indica uso nesta fase, não certificação de acabamento artístico comercial.

O fundo do jardim, o novo bloco de grama, os quatro retratos e os objetos de letra, velocidade, retorno e chegada completam o conjunto. As bases `pixel-master-v1.png` e a folha `garden-pixel-modules-v1.png` têm fundo opaco e servem apenas de referência.
