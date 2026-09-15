# Menu em pixel art e adaptação de tela — 0.10.0

A família enviou uma referência de menu de plataforma e pediu uma abertura atraente, mantendo as cores e a arte que já existiam na Aventura das Letras.

## Nova abertura

O menu usa o pomar de primavera já gerado para o jogo, título desenhado com letras em blocos, verde do jardim, creme e destaque dourado no botão principal. Os quatro personagens aparecem animados na seleção; ao passar o mouse ou levar o foco até um personagem, ele comemora.

A referência orientou a apresentação dos botões grandes. As montanhas, os símbolos e as cores da imagem de referência não foram incorporados como arte do jogo. A cópia enviada está em referências do menu — registro local não distribuído (`references/menu/menu-plataforma-referencia.webp`). Não foram necessárias novas imagens geradas: cenário e personagens usam os assets existentes; o título é texto desenhado pelo jogo.

## Todos os acessos preservados

- Escolha de perfil: João Miguel, Luna e Convidado.
- Escolha dos personagens João Miguel, Luna, Lucas o Engenheiro e Samara.
- Botão principal que começa, continua ou avança a aventura conforme o progresso do perfil.
- Speed Run, escolha de fase, poderes e duração, sensor opcional, ajustes e saída.
- Indicação da próxima descoberta e do modo de duração escolhido.

O foco inicial fica no botão principal. Mouse, teclado e navegação por controle continuam disponíveis. Nas telas com rolagem, o foco leva o botão escolhido para a área visível.

## Tamanhos de tela

Em telas largas, o título e os personagens ficam ao lado das ações. Em telas estreitas, a composição passa para uma coluna. Quando a altura não é suficiente, há rolagem vertical, sem retirar opções do menu.

Os menus de poderes, fases, ajustes, sensor e pausa também se adaptam: categorias se distribuem em novas linhas, grades reduzem o número de colunas e o conteúdo pode rolar. O redimensionamento não troca o perfil nem reinicia a partida.

A área jogável mantém sua proporção 16:9, centralizada, com os controles completos visíveis. Em janelas muito altas ou muito largas, isso deixa faixas ao redor da área do jogo. A mudança adapta o menu; não transforma a fase em um mapa vertical.

## Verificação

77 verificações de responsividade e navegação — registro local não distribuído (`evidence/responsive-menu-tests.json`) aprovadas nos tamanhos 320×568, 390×844, 640×360, 800×600, 960×540, 1280×720, 1920×1080 e 2560×1080. Incluem os menus secundários, acesso aos botões por foco, quatro personagens, troca de perfil/personagem, entrada no jogo, Speed Run e enquadramento da área jogável.

Também foram feitas capturas em janelas reais do Godot, incluindo a abertura em formato vertical. Isso valida tamanhos de janela neste Mac; não representa um teste em celulares ou tablets físicos.

Foram repetidas as verificações de conteúdo e cenários — registro local não distribuído (`evidence/curriculum-tests.json`), regressão geral — registro local não distribuído (`evidence/acceptance.json`), poderes e continuidade — registro local não distribuído (`evidence/powers-continuity-tests.json`), Speed Run — registro local não distribuído (`evidence/speedrun-tests.json`), pausa por foco — registro local não distribuído (`evidence/window-focus-tests.json`) e menus secundários — registro local não distribuído (`evidence/power-ui-tests.json`). Os testes usam perfis separados dos perfis da família.

Verificação do pacote 0.10.0 — registro local não distribuído (`evidence/pack-verification-v010.json`) · Versão e hash — registro local não distribuído (`release/verification.json`).

## Espaço durante a atualização

O Mac impediu gravações por falta de espaço. Foi removida apenas a cópia de download `tools/runtime/godot-arm64.gz`, com 83.092.895 bytes, após confirmar que seu conteúdo descompactado tinha o mesmo SHA-256 do executável já instalado. O Godot instalado, as versões do jogo, fotos, fontes do projeto e salvamentos foram preservados.

## Telas

Menu horizontal — registro local não distribuído (`evidence/v10-menu-960x540.png`)

Menu vertical — registro local não distribuído (`evidence/v10-menu-390x844.png`)

Referências técnicas consultadas pelo Context7: [redimensionamento de Window](https://docs.godotengine.org/en/4.7/classes/class_window.html), [configurações de escala](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html) e [SubViewportContainer](https://docs.godotengine.org/en/4.7/classes/class_subviewportcontainer.html).
