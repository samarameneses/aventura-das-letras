# Jogar com o sensor pela USB

A ESP32 já está com o controle do jogo instalado e a calibração em repouso foi testada no Mac. Não é necessário publicar o jogo nem instalar Arduino para jogar.

1. Conecte a ESP32 ao Mac pelo cabo USB, mantendo os fios do sensor como no teste.
2. Abra **launchers/macos/Jogar com sensor USB.command**, na pasta do jogo. Ele abre a conexão e o jogo juntos, no modo **Speed Run com movimento**.
3. Deixe o sensor imóvel sobre a mesa por cerca de três segundos. Aguarde **Sensor pronto**.
4. Clique em **Entrar no jardim**. O personagem corre automaticamente; você pula com o sensor e usa os poderes pelos botões ou teclado.
5. Ao terminar, feche a janela do jogo; a conexão USB é encerrada junto.

## Primeiro teste de movimento

A leitura e a calibração estão confirmadas. O usuário confirmou que o movimento já acionou o pulo. Ainda é necessário validar a montagem corporal e ajustar a sensibilidade durante o uso real. Não pule com o conjunto solto ou preso ao computador por um cabo curto. Faça primeiro a montagem firme e proteja os contatos e fios; um adulto deve realizar o primeiro teste. Para uso das crianças com liberdade de movimento, a etapa seguinte será Wi-Fi com alimentação portátil adequada. Apenas inclinar a placa não é um comando de pulo: o detector procura um impulso seguido de redução da aceleração.

## Se não aparecer Sensor pronto

- Deixe o sensor parado e confira se a USB continua conectada.
- Se desconectar ou precisar reposicionar os fios, feche o jogo e retire a USB antes de alterar a montagem.
- Conecte somente uma ESP32 CP2102 durante este teste.
- Se aparecer conexão ocupada, feche a outra janela que esteja usando o sensor.
- Você pode escolher **Jogar sem sensor** a qualquer momento.

O Wi-Fi ainda está desativado na placa. O firmware instalado funciona por USB.

## Correção do acesso após calibrar

A tela podia ficar em “Calibrando” se a confirmação chegasse antes do mínimo de três segundos contado pelo Godot, ou se um pacote UDP fosse perdido. O receptor agora repete a confirmação a cada meio segundo, somente enquanto recebe amostras válidas e o detector permanece calibrado. A perda de dados continua invalidando a calibração.

O painel de calibração foi centralizado, com título, instrução e botões maiores. Os 14 testes do receptor e a integração de corrida automática passaram. Na verificação visual após reabrir, a partida já estava em execução no Speed Run.

## Pulos sucessivos

O registro do receptor mostrou vários movimentos reconhecidos durante a partida. Um teste isolado do receptor Godot ligado à física do personagem reproduziu a perda de comandos durante o voo: oito comandos aceitos resultavam em quatro pulos. O buffer de teclado de 130 ms era curto para um movimento recebido antes da aterrissagem.

O personagem agora guarda um único comando de movimento por até 850 ms, consome-o ao poder pular e cancela-o ao pausar ou retornar a um ponto seguro. Novos comandos substituem o pendente; não há uma fila que continue pulando sozinha. O teclado conserva seu comportamento anterior. A regra de tocar o chão para um pulo comum permanece; os poderes de salto extra continuam disponíveis.

Depois da correção: oito comandos, oito pulos. A reconexão e o cancelamento do comando pendente também passaram. Quinze testes Python passaram, incluindo oito gestos sintéticos consecutivos com identificadores distintos. Evidência: `evidence/sensor-repeat-jumps.json`. Essas verificações automatizadas não substituem repetir o movimento real com o usuário; não foi alterada a sensibilidade do sensor nem o firmware nesta correção.

## Calibração com leituras reais do usuário

Uma coleta USB registrou movimentos com rotação que excedia o corte de 180 graus/s. Reproduzindo exatamente o mesmo trecho de dados, o detector antigo gerou apenas 1 pulo; com corte de 270 graus/s, gerou 4. Limites ainda maiores não acrescentaram pulos nesse trecho, por isso foi escolhido 270 graus/s. Mantidos o impulso, a redução de aceleração, o intervalo de 650 ms e a calibração em repouso. O firmware da ESP32 não precisou ser regravado.

Dezessete testes passaram, incluindo gestos repetidos com rotação e rejeição de rotação isolada. Resultado da reprodução: `evidence/motion-calibration-replay.json`. A melhoria na reprodução não equivale a validar todos os pulos reais, nem a medir quantos gestos a pessoa pretendia fazer. Foi aberto um novo teste ao vivo.

Para diagnóstico futuro: `tools/play_sensor_usb.py --diagnose` ativa uma coleta local limitada a 180 segundos em `firmware/local/motion-trace.jsonl` e `game-motion-trace.jsonl`, sem gravar a chave de pareamento. O modo normal não grava essas leituras. O detector, a chegada do comando e a física do personagem são registrados separadamente.

### Validação ao vivo após ajustar

No novo teste real com o usuário, dez comandos foram detectados pelo receptor, dez chegaram ao Godot durante a partida e dez pulos foram executados pelo personagem. A entrega entre o envio no Mac e a recepção no Godot ficou aproximadamente entre 2 e 13 ms. Esse intervalo não mede a latência física total (não inclui a classificação do gesto nem a exibição do quadro). Nove dos dez comandos chegaram com o personagem no chão.

Evidência: `evidence/motion-calibration-live.json`; amostras e eventos detalhados preservados somente em `firmware/local/`, fora do Git. O teste confirma a execução dos comandos detectados; não permite saber quantos movimentos a pessoa pretendia realizar ou afirmar que todos os obstáculos foram ultrapassados. A partida foi mantida aberta para continuar o uso.
