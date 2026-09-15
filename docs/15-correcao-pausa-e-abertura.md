# Correção de pausa e abertura — 0.5.1

O editor estava aberto sem uma instância do jogo em execução. Para jogar diretamente, abra Aventura das Letras.app. Pelo Godot, use ▶ Executar projeto no canto superior direito; depois escolha Começar aventura ou Continuar aventura no menu do jogo.

O registro da execução anterior também mostrou que a perda de foco podia tentar reconstruir o menu enquanto o Godot removia ou adicionava elementos à cena. A pausa agora agenda a reconstrução para o momento seguro seguinte, verificando se o jogador ainda está na partida. O cronômetro para imediatamente. O foco dos botões só é aplicado se o botão ainda estiver em uma janela visível.

Seis testes específicos passaram: perda de foco durante remoção de elemento, pausa visível, personagem pausado, continuação da corrida, preservação de uma tela aberta depois da notificação e troca rápida de menus. As 42 verificações de Speed Run também passaram. Os dados das fases e o formato de salvamento permanecem os mesmos.

[Relatório de foco](../evidence/window-focus-tests.json) · [Relatório de Speed Run](../evidence/speedrun-tests.json)
