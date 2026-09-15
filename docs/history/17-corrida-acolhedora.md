# Corrida acolhedora — versão 0.7.0

> Histórico da versão 0.7.0. A família pediu remover também a pergunta de nova tentativa. A [versão 0.8.0](18-brincadeira-sem-interrupcoes.md) segue sem avisos, perguntas ou pausas por erro.


Atualização de 7 de setembro de 2026, seguindo o pedido da família: deixar passar uma atividade não deve provocar pedido de repetição nem retorno obrigatório.

## Jogar e explorar

No Speed Run, o personagem continua correndo se a criança não pular ou não encostar numa opção. Não aparece mensagem de erro ou de nova tentativa. Nenhum coração é retirado e não há retorno automático à pergunta. Passar uma opção não é registrado como resposta errada nem como acerto.

O portal aceita a chegada mesmo quando há atividades deixadas para trás. A tela final comemora a chegada e informa somente as descobertas realmente feitas. Tempos de corridas com todas as descobertas continuam sendo os únicos comparados nos recordes pessoais; os recordes existentes permanecem guardados.

## Quando a criança pega outra opção

Uma escolha diferente da solicitada ainda retira um coração, conforme a regra de vidas pedida anteriormente. No Speed Run, o jogo pausa no local e mostra **Vamos tentar mais uma vez?**, com o texto: “Tudo bem! Suas descobertas continuam aqui. Você também pode seguir brincando.”

- **Tentar mais uma vez:** retorna apenas à aproximação da pergunta atual. Acertos anteriores, ponto de retorno, poderes e tempo acumulado permanecem.
- **Continuar brincando:** segue do mesmo lugar e deixa aquela pergunta para trás, sem transformá-la em acerto.
- **Voltar aos personagens:** retorna ao menu voluntariamente.

O tempo para enquanto a criança escolhe. Quando os corações chegam a zero, tentar ou continuar renova os três corações e mantém a mesma corrida. Não há reinício automático da fase como consequência de um erro.

Na aventura com movimento manual, a criança recebe uma mensagem acolhedora após errar e continua livre para se posicionar. Ao esgotar os corações, a continuação também preserva os acertos, o ponto de retorno e os poderes. Reabrir uma aventura salva com zero corações oferece continuar com vidas renovadas, preservando as descobertas salvas.

## Outras regras preservadas

As 68 fases, as 332 atividades, os quatro personagens, os cenários de primavera/outono e as comemorações de acerto continuam disponíveis. O jogo funciona sem sensor. O reconhecimento com sensor físico continua pendente de teste com a família.

Quedas no vão ainda retornam ao ponto seguro, mantendo acertos e corações. **Reiniciar corrida** na pausa e **Jogar outra vez** no final são escolhas voluntárias para iniciar outra partida. Corridas continuam separadas do progresso da aventura; sair de uma corrida não salva sua posição para retomada posterior.

## Verificação

- 18 verificações da experiência acolhedora — registro local não distribuído (`evidence/gentle-flow-tests.json`): corrida inteira sem coletar opções, ausência de retorno e penalidade por passagem, escolha após erro, renovação dos corações, preservação de descobertas/ponto de retorno/poderes/tempo e final com parte das atividades coletadas.
- 88 verificações de vidas e corrida — registro local não distribuído (`evidence/lives-autorun-tests.json`), incluindo conclusão das 68 fases usando apenas saltos.
- 38 verificações de cronômetro e recordes — registro local não distribuído (`evidence/speedrun-tests.json`).
- 397 verificações de conteúdo e cenários — registro local não distribuído (`evidence/curriculum-tests.json`) e 100 verificações gerais — registro local não distribuído (`evidence/acceptance.json`).
- Verificação do pacote entregue — registro local não distribuído (`evidence/pack-verification-v07.json`).

As verificações usam perfis de teste, separados dos perfis da família. Não houve alteração no conteúdo pedagógico nem no formato do salvamento.

## Telas

Escolha acolhedora após pegar outra opção — registro local não distribuído (`evidence/v07-escolha-acolhedora.png`)

Chegada após continuar explorando — registro local não distribuído (`evidence/v07-chegada-com-descobertas.png`)

O aplicativo local abre `release/Aventura.pck`, correspondente à versão 0.7.0. O pacote anterior está preservado em `release/Aventura-v0.6.pck`. Versão e verificação — registro local não distribuído (`release/verification.json`).
