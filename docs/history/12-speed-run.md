# Speed Run — versão 0.3.0

> As regras mudaram na versão 0.6.0: agora o personagem corre automaticamente e há três vidas. Veja [Vidas e corrida automática](16-vidas-e-corrida-automatica.md). Esta página registra o modo manual anterior.

> Atualização 0.4.0: agora são 48 fases, com 30 palavras monossílabas e cenários de primavera/outono. Veja [Palavras e estações](13-palavras-e-estacoes.md). Os números abaixo registram a entrega anterior.

## Como entrar

Escolha o perfil e o personagem no início e clique em **Speed Run**. Depois escolha a fase. As 42 fases estão disponíveis e o mapa mostra o recorde pessoal de cada uma.

O objetivo é completar todas as letras/sílabas pedidas e alcançar o portal no menor tempo. A corrida começa do início, mesmo que a fase já tenha sido jogada na aventura. A velocidade, os saltos e o poder de velocidade seguem as mesmas regras do jogo normal: Speed Run é uma corrida contra o relógio, sem corrida automática.

## Cronômetro e recordes

- O cronômetro começa quando o personagem fica disponível para jogar e termina no portal, após todas as respostas corretas.
- O tempo aparece no alto da tela em minutos, segundos e centésimos.
- Pausa, perda de foco da janela, ajustes e desconexão do sensor param o relógio. Retomar continua do mesmo tempo.
- Quedas retornam ao ponto seguro sem zerar o cronômetro. Respostas diferentes permitem nova tentativa, sem multa artificial de tempo.
- **Reiniciar corrida**, no menu de pausa, começa outra tentativa do zero.
- Só corridas concluídas geram recorde. Tentativas abandonadas não são retomadas ao reabrir o aplicativo.
- O resultado mostra o tempo da tentativa, o melhor tempo e uma comemoração quando há novo recorde. Uma corrida mais lenta não substitui o melhor tempo.

Os recordes são locais e separados por perfil e fase. Os quatro personagens compartilham o recorde daquele perfil, pois usam a mesma física. Teclado, controle e sensor opcional participam dessa mesma marca pessoal. Não há ranking online.

## Progresso da aventura

O Speed Run usa uma partida temporária, separada das respostas, checkpoints, poderes e histórico pedagógico da aventura. Ao voltar à aventura, a fase que estava selecionada antes de entrar no modo é restaurada. Somente os recordes do Speed Run são acrescentados ao salvamento normal.

Os arquivos da versão 2 do salvamento continuam compatíveis; o campo opcional `speedrun_records` é criado quando houver uma corrida concluída. Fotos e imagens não foram alteradas nesta atualização.

## Implementação e verificação

`game/scripts/run_clock.gd` mede intervalos usando o relógio monotônico do motor e acumula apenas o tempo ativo. A alteração do relógio/calendário do Mac não muda a medição. [Documentação do Godot — Time](https://docs.godotengine.org/en/4.7/classes/class_time.html), consultada por Context7.

`evidence/speedrun-tests.json` registra 42 verificações aprovadas: cronômetro, pausa/retomada, queda, percurso físico da família B, coleta obrigatória, recorde melhor/pior, duplicidade, abandono, isolamento do progresso, restauração da fase normal e persistência por perfil/fase. As 100 verificações de regressão da aventura e dos controles também passaram em `evidence/acceptance-v03.log`.

As telas foram renderizadas no Mac e estão em `evidence/speedrun-menu.png`, `speedrun-stages.png`, `speedrun-playing.png`, `speedrun-pause.png` e `speedrun-result.png`. A tela de resultado foi preparada com respostas de teste para conferir o layout; o percurso físico foi verificado separadamente. Nenhum tempo dessas capturas foi gravado como recorde de um perfil real da família.
