# Interface limpa e controles por ícones — 0.11.0

7 de setembro de 2026.

A partida usa ícones desenhados pelo Godot na paleta do jogo, sem barra superior branca ou fundos retangulares. O menu principal mantém sua estética atual.

- Inferior esquerdo: dois poderes equipados; oito desenhos diferentes para os oito poderes. Pontos abaixo indicam recarga e o ícone acende durante o efeito.
- Inferior direito: seta de salto com área de clique maior que o desenho.
- Superior direito: alto-falante para repetir a instrução e duas barras para pausar.
- Centro superior: objetivo da atividade, com contorno escuro para leitura sobre o cenário.
- Superior esquerdo: corações, descobertas e cronômetro quando em Speed Run.

Os nomes e atalhos aparecem ao passar o mouse; o teclado e o controle continuam funcionando. As comemorações têm texto contornado, sem painel opaco. Foi removido o aviso inicial de atalhos. Erros continuam sem anúncio, pausa ou retrocesso.

## Validação

47 verificações específicas da interface passaram, incluindo posição dos controles em 960×540, 640×360, 390×844 e 1920×1080; 43 verificações de poderes e continuidade e 25 de fluxo agradável passaram. Capturas nativas estão em `evidence/v11-controles-*.png`. O jogo mantém a área de ação em 16:9, com margens em janelas verticais; o tamanho dos controles acompanha essa área, sem prometer otimização para toque em telefone.

![Interface em jogo](../evidence/v11-controles-960x540.png)

O pacote é verificado antes da substituição do lançador local. Fotos, conteúdo pedagógico e progresso familiar foram preservados. O sensor físico não foi testado nesta alteração.

## Atualização 0.11.1 — menu maior no computador

A janela inicia maximizada, com alternativa de 1280×720 ao restaurar. O menu principal deixa de limitar sua escala a 1,3 e passa a crescer com a largura e a altura disponíveis, até 3. As telas menores mantêm o fluxo responsivo.

77 verificações de menus em oito resoluções passaram. Na captura nativa do Mac, a área do jogo foi 3024×1704 e o botão principal mediu 1026×162 pixels; os quatro testes confirmaram ocupação da tela, ampliação dos botões e personagens e ausência de rolagem no menu desktop. O macOS reportou modo de janela normal mesmo com a geometria maximizada, portanto a validação usa a área disponível efetivamente ocupada.

![Menu ampliado](../evidence/v111-menu-desktop.png)
