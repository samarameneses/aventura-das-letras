# Teste controlado de resposta do sensor

## Resultado inicial — 12/09/2026

O painel do teste físico registrou 50 comandos recebidos e 50 saltos executados. A última espera entre receber o comando no jogo e iniciar o salto foi de 16 ms; o último tempo de voo foi de 700 ms. Esses contadores não revelam quantos movimentos físicos foram ignorados pelo detector. A captura detalhada anterior já havia terminado antes dessa rodada; não há base para atribuir individualmente as falhas relatadas a uma orientação ou limiar.

O usuário observou melhor reconhecimento em movimentos mais lentos, falhas em movimentos rápidos e em algumas orientações, e pediu uma descida mais rápida.

## Experimento atual

A cena `game/tests/sensor_latency_lab.tscn` usa o jogador real em piso plano, sem obstáculos ou poderes. Nesta rodada, somente a gravidade durante a descida foi multiplicada por dois. A subida mantém a aceleração e velocidade iniciais. O teste de física mediu 600 ms no ar, comparados a 700 ms antes, mantendo a altura medida de 42,308 pixels. Evidências: `evidence/player-flight-before.json` e `evidence/player-fast-fall.json`.

O multiplicador é uma propriedade do jogador com valor padrão 1. A cena de teste configura o valor 2; as fases normais ainda usam o valor padrão enquanto esta avaliação controlada está em andamento. A queda mais rápida também reduz o alcance horizontal do salto, que deverá ser validado nos obstáculos antes de aplicar o valor ao jogo inteiro.

## Reconhecimento dos movimentos

Os limiares do detector permanecem os mesmos nesta rodada: impulso acima de 1,4 vezes o repouso, redução abaixo de 0,72 por pelo menos 25 ms dentro de 350 ms, intervalo mínimo entre detecções de 650 ms e cancelamento de gesto acima de 270 graus/s. A magnitude é matematicamente invariável à orientação dos eixos; isso não elimina efeitos de rotação física, diferenças entre movimentos, ruído, erros de escala ou saturação do sensor.

Hipóteses a distinguir com nova captura: movimentos separados por menos de 650 ms; rotação que ultrapassa o limite; fase de baixa carga curta demais ou ausência do padrão de impulso; e espera por aterrissagem após o comando já ter chegado ao jogo. Não reduzir todos os limiares de uma vez.

## Registro da nova rodada

O receptor e os eventos do jogador registram até 15 minutos no laboratório. O receptor inicia a contagem no primeiro evento gravado. Os dados ficam em `firmware/local/latency-motion.jsonl` e `firmware/local/game-motion-trace.jsonl`, sem chave de pareamento. O estado atual fica em `evidence/sensor-latency-live.json`. Registros anteriores foram copiados antes da reabertura.

O relógio da ESP32 permite medir a duração do padrão de movimento. Os eventos do Mac permitem medir a espera dentro do jogo e o voo. O atraso absoluto entre o início físico do movimento e a imagem exibida não é medido diretamente por esses registros; não confundir o último tempo de espera no jogo com a latência total do sistema.

Executar pelo Python local: `tools/.sensor-venv/bin/python tools/run_sensor_latency_lab.py`. Manter a placa parada até o painel indicar pronto, testar a descida e repetir movimentos lentos e rápidos. A sensibilidade só deve ser alterada depois de comparar essa captura e verificar também movimentos que não deveriam gerar pulo.

## Segunda análise e ajuste de rotação

A nova captura registrou 87 comandos recebidos e 87 saltos executados; todos chegaram com o personagem no chão. A espera entre recebimento e salto ficou entre 3,2 e 18,4 ms, com mediana de 16,2 ms. O tempo de voo ficou entre 586,1 e 616,3 ms, com mediana de 599,8 ms. Portanto, nessa rodada o bloqueio relatado dos movimentos rápidos ocorreu antes da execução no jogador.

Repetições da mesma captura variando um parâmetro por vez:

| Variante | Eventos reconhecidos |
| --- | ---: |
| Original: limite de rotação 270°/s | 87 |
| Somente limite de rotação 450°/s | 142 |
| Somente limite de rotação 600°/s | 143 |
| Somente intervalo mínimo 450 ms | 76 |
| Somente baixa carga mínima 15 ms | 88 |

Um intervalo menor pode mudar quais impulsos são aceitos primeiro e a sequência de estados; a contagem não é necessariamente crescente. Eventos adicionais não são uma verdade de referência: a captura não tinha rótulos de cada intenção do usuário, e falsos positivos ainda precisam de avaliação física.

Foi alterado somente o limite de rotação, de 270 para 450°/s, mantendo os demais limiares de reconhecimento. A alteração está no receptor compartilhado do projeto, e o laboratório foi reaberto com ela. Os 22 testes Python passaram, incluindo casos de movimento rápido com 420°/s, equivalência entre os três eixos e sinais, e rotação sem a sequência de impulso/baixa carga que não deve gerar pulo. Dois desses casos falhavam antes do ajuste. A queda rápida continua exclusiva da cena de teste nesta etapa.

Evidências: `evidence/rapid-motion-replay.json` e `evidence/sensor-latency-before-rotation450.json`. A aprovação da sensação e a avaliação de falsos positivos após o novo limite dependem da próxima rodada física.

## Rodada de 400 ms

Após o usuário considerar bom o ajuste anterior, foi solicitado reduzir para 400 ms a medida de voo mostrada no painel. O laboratório passou a usar `jump_time_scale=1.5`, com a gravidade de descida ainda multiplicada por dois. Velocidade inicial e limite de queda são escalados linearmente; gravidade é escalada pelo quadrado. Isso encurta subida e descida mantendo aproximadamente a altura, em vez de fazer apenas a queda abrupta.

Teste de física: tempo total no ar de 400 ms; altura de 43,300 pixels, contra 42,308 pixels na rodada de 600 ms. A diferença de aproximadamente um pixel decorre da integração em passos de física. Evidências: `evidence/player-fast-fall.json` e `evidence/player-flight-600ms.json`. O intervalo mínimo do detector continua em 650 ms; este ajuste não altera a frequência de reconhecimento dos gestos. Os multiplicadores continuam configurados somente no laboratório.

## Percurso com buraco e painel visual

A cena de entrada do laboratório agora usa `game/tests/sensor_gap_lab.gd`. A interface reutiliza o cenário de primavera e as texturas do jogo, com câmera ampliada três vezes e HUD em CanvasLayer. A câmera amplia a imagem sem escalar a física. A janela mantém as proporções ao redimensionar.

O painel mostra conexão do sensor, último tempo no ar, espera dentro do jogo, saltos/comandos e travessias. Comandos recebidos durante pausa ou preparação são contados, mas não ficam enfileirados para saltar depois. Clique **Começar percurso** para iniciar a corrida automática a 110 pixels/s. A faixa dourada indica uma região inicial de referência para o salto; não aciona o pulo automaticamente.

O buraco padrão tem 32 pixels, como o vão básico do jogo. O seletor permite 24, 32, 40 e 48 pixels. Mudar a largura reposiciona o personagem no início. Cair retorna ao início após uma breve preparação, sem vidas, penalidades ou sobreposição de erro. Ao completar a volta, o percurso também se repete. Os controles permitem pausar, voltar ao início ou reconectar. Os poderes e comandos de movimento por teclado estão desativados neste experimento para isolar o sensor.

`game/tests/sensor_gap_probe.gd` verifica o percurso real com comandos simulados: sem pular ocorre retorno; com pulo próximo da borda o vão de 32 pixels é atravessado em aproximadamente 401 ms, com alcance medido de 45,834 pixels; um vão de 48 pixels, na mesma condição de partida do salto, leva ao retorno. Isso valida a física e o percurso, não o tempo de reação físico de uma pessoa. Evidência: `evidence/sensor-gap-physics.json`.

O receptor continua gravando os movimentos. O laboratório acrescenta eventos de travessia, retorno e reinício. `--preview` no lançador salva uma imagem renderizada pela própria cena em `evidence/sensor-gap-preview.png`; ela é uma captura inicial de layout e pode mostrar o sensor aguardando enquanto a calibração ainda começa.


## Correção da abertura da janela no macOS

O lançador gráfico passava `--test` depois do separador `--` para isolar o progresso. Na inicialização nativa do Godot no macOS, esse nome também é reservado e seleciona a implementação sem o ciclo de eventos da janela. A cena renderizava e recebia dados do sensor, mas a janela interativa não funcionava. A verificação de cliques simulados no viewport não detectava essa falha de inicialização nativa.

O lançador agora usa somente a opção própria `--sensor-latency-lab`, que também direciona o Data para `evidence/test-progress.json`. O progresso da família continua isolado. A opção `--test` permanece disponível nos testes sem interface.

Validação no Mac: janela nativa acessível, sensor pronto, clique real por automação de interface em **Começar percurso** alterando `running` para verdadeiro e personagem correndo, com retornos registrados ao cair no buraco. Evidência: `evidence/sensor-gap-native-button.json`. Os registros temporários de posição do mouse foram removidos. O aplicativo separado criado durante a investigação foi removido; o teste usa o Godot original do projeto.


## Ajuste aprovado integrado ao jogo

Após a aprovação do percurso pelo usuário, o jogo completo passou a aplicar o perfil de salto do laboratório sempre que o modo com sensor está ativo: escala de tempo 1,5 e gravidade de descida multiplicada por 2, com voo básico de aproximadamente 400 ms. O jogador e o laboratório compartilham `Player.configure_sensor_jump`, evitando valores independentes. Iniciar uma fase ou retomar a partida aplica o perfil correspondente ao modo; continuar sem sensor restaura o salto manual anterior. Poderes que alteram o voo continuam podendo mudar sua duração.

A sensibilidade de rotação de 450°/s já integra o receptor compartilhado e permanece em uso. O intervalo mínimo de reconhecimento de 650 ms não foi alterado. O atalho `Jogar com sensor Wi-Fi.command` abre o jogo completo, prepara a conexão e seleciona a corrida automática.

Validação: física de voo de 400 ms e altura de 43,300 pixels; teste no cenário real com sinal de sensor simulado coleta a letra correta e atravessa lava e buraco sem dano ou retorno. A troca para botões restaura o perfil manual. Evidências: `evidence/player-fast-fall.json` e `evidence/sensor-game-jump.json`. Esses testes validam a integração e a física; não medem a latência física total da placa.
