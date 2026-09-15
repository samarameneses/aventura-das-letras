# Vidas e Speed Run automático — 0.6.0

> Registro histórico da versão 0.6.0. As regras de retorno obrigatório e reinício por falta de corações foram substituídas na [versão 0.7.0 — corrida acolhedora](17-corrida-acolhedora.md).


Entrega de 7 de setembro de 2026. O modo Speed Run anterior cronometrava uma partida com movimento manual. Agora o personagem **corre automaticamente**, conforme solicitado, e todas as fases passam a usar **três vidas**.

## Regras das vidas

- Cada fase ou nova tentativa começa com três corações visíveis no canto superior direito.
- Pegar uma letra, sílaba, palavra ou quantidade diferente da pedida tira uma vida.
- A mesma colisão durante um salto não pode tirar várias vidas; um novo salto permite uma nova escolha.
- Acertos mantêm as vidas. Cair no vão provoca retorno ao ponto seguro, sem contar como erro de leitura ou gastar uma vida.
- Ao zerar, o personagem e o cronômetro param. A tela **Vamos tentar de novo?** oferece **Recomeçar com 3 vidas**, escolher outra fase ou voltar aos personagens.
- Recomeçar apaga as descobertas daquela tentativa, restaura três vidas e volta ao começo da fase. O histórico e as outras fases continuam salvos.
- Na aventura normal, as vidas são salvas por fase e perfil. Pausar, sair ou abrir o menu não restaura corações automaticamente. Abrir uma fase esgotada mostra novamente a opção de recomeçar.
- Speed Run usa vidas separadas, começando cada corrida com três corações, sem alterar as vidas ou descobertas da aventura.

## Como jogar Speed Run

Escolha **Speed Run → fase** no menu inicial. O personagem começa a correr para a direita. As setas não controlam o deslocamento nesse modo. Use **Espaço** para saltar na opção correta e sobre o vão, **E** para o poder coletado, **H** para ajuda, **R** para ouvir novamente e **Esc** para pausar. As teclas remapeadas continuam funcionando. No controle compatível: A pula e X usa o poder.

A instrução aparece antes da janela de salto. As duas opções continuam distribuídas ao longo do caminho: espere a opção pedida e salte para alcançá-la. Ao passar por uma opção diferente, apenas siga correndo. Se passar por ambas sem acertar, o personagem retorna para uma nova aproximação daquela pergunta, mantendo as vidas; o relógio continua. Uma escolha errada tira um coração e também retorna à aproximação. Isso permite jogar sem precisar andar para trás.

A corrida usa uma versão do percurso sem plataformas suspensas que bloqueariam o avanço automático. O vão, as perguntas, os cenários, o ponto de retorno, o poder e o portal continuam presentes. A aventura normal mantém suas plataformas e movimento manual. A velocidade básica automática é 110 unidades por segundo; o poder multiplica por 1,65 fora da região das escolhas e dura seis segundos ativos.

O cronômetro começa com a corrida, para durante pausas/perda de foco/desconexão e termina no portal. É preciso acertar todas as atividades com pelo menos uma vida restante. Zerar vidas encerra a tentativa sem registrar tempo. A tela final mostra o tempo e o melhor resultado da fase/perfil. A tecla de pausa continua disponível durante todo o percurso.

## Salvamento e compatibilidade

O formato principal permanece v2. Salvamentos anteriores sem o campo de vidas são aceitos com três corações disponíveis. Valores inválidos são rejeitados na validação, e a cópia de segurança continua disponível.

Os recordes da antiga corrida manual permanecem em `speedrun_records`. Os novos tempos automáticos são gravados em `autorun_records`, porque o movimento e a geometria do percurso mudaram. A interface do novo Speed Run usa somente os novos recordes. Não houve remoção do histórico antigo nem das 68 fases/332 atividades.

O aplicativo abre o menu normalmente. Para atender à abertura direta da partida nesta conversa, também foi acrescentado o argumento opcional `--speed-run`: ele inicia a corrida na fase e com o personagem do perfil atual, preservando a aventura.

## Verificação

- [88 verificações de vidas e corrida automática](../evidence/lives-autorun-tests.json): vidas, erros, repetição de colisão, esgotamento, reinício, persistência, compatibilidade, separação de recordes, poder e conclusão das **68 fases usando apenas saltos**, sem comandos de direção.
- [38 verificações de cronômetro e recordes](../evidence/speedrun-tests.json): pausas, quedas, conclusão, melhor tempo, reinício e preservação do progresso normal.
- [397 verificações de conteúdo e percurso normal](../evidence/curriculum-tests.json): todas as fases, letras, sílabas, palavras, cenários, textos e salvamento.
- [100 verificações de regressão](../evidence/acceptance.json): quatro personagens, controles, quedas, poderes, salvamento e comunicação local simulada.
- [Seis verificações de foco de janela](../evidence/window-focus-tests.json).
- [Conferência visual da interface](../evidence/autorun-ui.json) e [teste de abertura direta](../evidence/direct-speedrun-tests.json).

Capturas: [corrida e três corações](../evidence/v06-corrida-automatica.png), [vida perdida](../evidence/v06-dois-coracoes.png), [recomeçar](../evidence/v06-recomecar.png).

Os testes usam arquivos próprios, sem preencher conquistas nos perfis da família. Sensor físico e controle físico continuam dependendo de validação com os dispositivos da família; os comandos simulados e a comunicação local foram testados.

O pacote final 0.6.0 também foi validado, incluindo movimento automático real sem direção pressionada e três corações na interface. [Verificação do pacote](../evidence/pack-verification-v06.json) · [Versão e hash](../release/verification.json). A versão anterior permanece em `release/Aventura-v0.5.1.pck`.
