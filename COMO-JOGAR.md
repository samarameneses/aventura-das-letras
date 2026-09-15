# Aventura das Letras — como jogar

> **Instalação pelo GitHub:** importe `game/project.godot` no Godot 4.7.2 e pressione F5, ou execute `python3 tools/run_game.py`. Referências abaixo a aplicativos exportados são opções de instalações locais; consulte o [README](README.md) e o [guia do sensor](docs/SENSOR.md) para um clone novo.

**Erros e acertos (11/09/2026):** errar toca um som breve e mostra um aviso, sem voltar ao início. Quando os corações acabam, as três vidas se renovam no mesmo lugar e os acertos são mantidos. Acertar dispara uma explosão de confetes no personagem e uma chuva colorida pela tela, com um som alegre. Vale para aventura e Speed Run; substitui a regra anterior de reiniciar a família.

Alfabeto, sílabas e palavras para este Mac Apple Silicon, versão 0.12.0, 8 de setembro de 2026.

## Abrir

Na pasta do projeto, abra **Aventura das Letras.app** com dois cliques. O arquivo **Jogar.command** é uma segunda forma de abrir o mesmo jogo. Não é necessário instalar o editor nem conectar o sensor. Mantenha as pastas `tools/runtime` e `release` junto do aplicativo: esta entrega é uma instalação local, não um aplicativo independente para enviar sozinho a outro computador.

Escolha quem vai brincar (João Miguel, Luna ou Convidado), depois escolha um dos quatro personagens e **Começar aventura**. O perfil guarda as descobertas; o personagem muda a aparência. Qualquer perfil pode escolher João Miguel, Luna, Lucas o Engenheiro ou Samara.

## Novo menu

A abertura mostra o pomar, os quatro personagens e as ações principais. Escolha o perfil, clique no personagem e use **Começar aventura** ou **Continuar aventura**. **Speed Run**, **Escolher fase**, **Poderes e duração**, **Com sensor**, **Ajustes** e **Sair** ficam na mesma tela.

Você pode redimensionar a janela. Em formato estreito, o menu vira uma coluna; quando necessário, role para ver as demais opções. Tab, setas e controle também levam o foco aos botões fora da área visível. As fases mantêm sua proporção original, sem esticar personagens. [Telas e detalhes](docs/20-menu-pixel-responsivo.md).

## Jogar pelo Godot

Com o projeto aberto no editor, clique no botão **▶ Executar projeto**, no canto superior direito, para abrir o jogo. No menu do jogo, escolha o perfil, o personagem e **Começar aventura** ou **Continuar aventura**. Você também pode abrir **Aventura das Letras.app** diretamente, sem passar pelo editor.

## Controles

| Ação | Teclado | Controle compatível |
| --- | --- | --- |
| Andar | Setas ou A / D | Direcional ou analógico esquerdo |
| Pular | Espaço | A |
| Usar o primeiro poder | E | X |
| Usar o segundo poder | Q | B |
| Ouvir a instrução novamente | R | Y |
| Pedir uma pista | H | RB |
| Pausar | Esc | Start |
| Navegar nos menus | Setas / Tab e Enter | Direcional e A |

Os nomes dos botões seguem a disposição Xbox; controles de outras marcas podem ter símbolos diferentes. A navegação foi testada com eventos simulados de controle; nenhum controle físico estava disponível.

Em **Ajustes**, troque teclas, ative/desative a narração ou regule seu volume. As instruções usam uma voz em português do Brasil instalada no Mac. A voz Luciana foi encontrada neste computador. Não há música ou efeitos sonoros nesta primeira entrega.

## A primeira aventura

Ande pelo jardim. Ao ouvir o pedido, fique abaixo da opção escolhida e pule para encostar nela. A trilha agora percorre todas as letras de **A a Z** e continua com famílias como **BA, BE, BI, BO, BU**, além de CH, LH, NH e encontros como BR e PR. São 68 fases curtas, incluindo seis fases com 30 palavras monossílabas e 20 fases com 100 palavras dissílabas. A fase original com A, M, L e três estrelas continua em **Escolher fase → Especiais**. Ao acertar, o personagem comemora e você ouve uma frase como “Isso, você acertou!!!”. Uma escolha diferente permite tentar novamente. A letra solicitada também aparece escrita: esta primeira fase trabalha reconhecimento com apoio visual.

Os dois poderes escolhidos ficam disponíveis desde o início e recarregam automaticamente. O tênis do caminho também recarrega os poderes. Há botões na própria tela para os dois poderes e para pular.

Ao cair no vão, o personagem retorna ao começo ou à bandeira já alcançada. As descobertas continuam guardadas. Cair não conta como erro de leitura.

## Jogar por mais tempo, sem parar a cada fase

O padrão agora é **duração contínua**: ao chegar ao portal, a aventura segue para o próximo trecho e seu novo cenário, sem abrir tela de conclusão nem pedir confirmação. O tempo total, as descobertas da sessão e os poderes ativos continuam. Depois do último trecho da trilha, a brincadeira volta ao alfabeto e pode seguir até você pausar.

Use **Esc → Poderes e duração** durante o jogo, ou **Poderes e duração** no menu. O botão **Duração: contínua — até você pausar** permite alternar para **uma fase por vez**, se preferir partidas curtas. Na aventura manual, o avanço continua dependendo das descobertas do trecho; no Speed Run, é possível seguir deixando opções passarem.

## Escolher e usar superpoderes

Em **Poderes e duração**, selecione **Poder 1** ou **Poder 2** e depois um dos oito poderes. Todos estão disponíveis para os quatro personagens. Se escolher um poder que já está no outro espaço, os dois trocam de lugar.

Use **E e Q** no teclado, **X e B** no controle ou os dois botões na tela. Os botões mostram o nome do poder, quando está ativo e sua recarga. **Espaço**, A no controle ou o botão **Pular** continuam acionando o salto. O sensor opcional também continua acionando o salto; não é necessário repetir saltos físicos para usar o pulo duplo, pois ele pode ser acionado por botão.

Os poderes são supervelocidade, pulo duplo, asas mágicas, ímã das letras, bolha flutuante, ponte de arco-íris, tempo de tartaruga e luz das descobertas. [Efeitos, duração e recarga](docs/19-aventura-continua-e-superpoderes.md).

## Palavras e mudança de cenário

Abra **Escolher fase → Palavras** para jogar com SOL, MAR, PÉ, MÃO, PÃO, FLOR, TREM e outras palavras de uma só sílaba. Há seis fases, com cinco palavras em cada uma. Elas também aparecem depois das sílabas na sequência da aventura e estão disponíveis no **Speed Run → Palavras**. Os acentos fazem parte da palavra e aparecem nos suportes maiores.

Ao escolher outra fase ou apertar **Próxima fase**, o cenário muda automaticamente. A trilha alterna primavera e outono: pomares floridos, lagos, bosques dourados e vales ao pôr do sol. Cada fase tem um enquadramento e cores próprios, que permanecem iguais ao repeti-la. O nome do cenário aparece no mapa.

[Lista das palavras e cenários](docs/13-palavras-e-estacoes.md).

## Nova etapa: 100 palavras dissílabas

Em **Escolher fase → Dissílabas**, escolha entre 20 fases de cinco palavras: brinquedos, casa, roupas, família, alimentos, animais e outros temas. São palavras como BOLA, CASA, MAMÃE, QUEIJO e BRINCAR. Use **H** para ver a divisão em duas sílabas. A etapa também funciona em **Speed Run → Dissílabas** e vem depois das monossílabas no avanço por **Próxima fase**.

[Lista das 100 palavras](docs/14-cem-palavras-dissilabas.md).

## Retomar depois

O jogo salva após as descobertas, no ponto de retorno e ao mudar configurações. **Continuar aventura** retoma o último ponto salvo. A posição exata de cada passo não é salva. **Repetir esta fase** reinicia somente a fase escolhida e mantém o histórico de tentativas e as outras fases. Use **Escolher fase** no início ou na pausa para praticar uma família específica.

O progresso fica em `~/Library/Application Support/Godot/app_userdata/Aventura das Letras/progress.json`, com uma cópia `.bak` para recuperação. Na primeira atualização, o arquivo antigo é preservado também em `.v1.bak`. Os testes usam arquivos separados na pasta `evidence`, sem preencher os perfis da família. Se o disco não permitir salvar, o jogo mostra uma mensagem.

## Vidas

Os três corações aparecem discretamente no canto superior. Pegar uma opção diferente da pedida tira um coração. Quando acabam, os três são renovados automaticamente, sem aviso, pausa ou reinício. As descobertas, o ponto de retorno e os poderes permanecem. Acertos, opções deixadas passar e quedas não gastam corações.

Na aventura, as vidas são salvas por fase e perfil. Um salvamento antigo sem corações retoma diretamente com três vidas, mantendo suas descobertas. As vidas do Speed Run são separadas da aventura.

## Speed Run

No menu, escolha **Speed Run** e depois a fase. O personagem corre sozinho para a direita. Use **Espaço** para pular e **E/Q** para os dois poderes; no controle, A para pular e X/B para os poderes. Deixar uma opção passar ou pegar outra opção não abre mensagens, não pausa e não faz voltar. A corrida continua para a próxima descoberta.

Os acertos continuam com comemoração. É possível chegar ao portal mesmo deixando atividades para trás. Quando a duração escolhida for uma fase por vez, a tela final mostra as descobertas realmente feitas; só corridas com todas as descobertas entram na comparação de recordes pessoais. Os recordes antigos permanecem guardados; os tempos com os novos poderes têm uma lista separada.

O cronômetro segue correndo após erros. A pausa voluntária e a proteção por perda de foco ou conexão do sensor continuam disponíveis. Quedas ainda retornam ao ponto seguro, preservando descobertas e corações.

**Reiniciar corrida** na pausa e **Jogar outra vez** no final são escolhas voluntárias para começar outra partida. Corridas ficam separadas da aventura e não guardam a posição ao sair para os personagens. [Atualização sem interrupções por erro](docs/18-brincadeira-sem-interrupcoes.md).

## Sensor opcional

O jogo funciona inteiro sem sensor. **Com sensor** está preparado para receber o salto de uma ponte local; o teclado/controle continua responsável por andar e também pode pular. Se a conexão cair, o jogo pausa e oferece **Continuar sem sensor**, preservando o progresso. Pausar e reconectar exige nova calibração.

A placa e o código do projeto de carros ainda não foram informados. A integração do sensor físico e o reconhecimento do gesto ainda não estão concluídos. O simulador entregue serve para testar a comunicação, não para colocar na criança. O [guia de integração](docs/10-entrega-e-sensor.md) registra o que está pronto e o que depende do hardware.

## Primeiro teste em família

Comece pelo teclado, com um adulto acompanhando. Observe se a criança entende como escolher, alcançar a letra e pedir uma pista. Registre quais instruções precisaram ser repetidas e se a altura/distância dos saltos está confortável. Esses resultados orientarão os ajustes de dificuldade e as próximas atividades com palavras mais longas e novos mundos. Consulte a [lista de famílias e combinações](docs/11-alfabeto-silabas-e-comemoracoes.md).

## Controles sobre o cenário

Os dois ícones no canto inferior esquerdo ativam os poderes escolhidos. Os pequenos pontos abaixo mostram a recarga. A seta no canto inferior direito pula; no alto à direita, o alto-falante repete a instrução e as duas barras pausam. Passe o mouse sobre um ícone para ver seu nome e a tecla correspondente. Espaço pula e E/Q ativam os poderes.

A instrução fica no alto ao centro, com corações e contagem discretos à esquerda. A interface não usa uma faixa branca nem fundos retangulares nos controles durante a partida.

O jogo abre com a janela maximizada no computador. O menu aumenta título, personagens e botões conforme a área disponível; continua adaptável ao redimensionar a janela.

## Lava, rios e pontes

Pule a lava e os troncos com Espaço. Se tocar na lava, perde um coração e reaparece na margem próxima com um foguinho breve, sem reiniciar. O rio é raso: molha os pés e não tira vidas. Atravesse as pontes andando. Os trechos alternam dia, entardecer e noite.
