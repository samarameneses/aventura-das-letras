# Brincadeira sem interrupções — 0.8.0

A família considerou a tela de nova tentativa desagradável. A atualização remove essa tela, seus botões e a fala de tentar novamente, em vez de apenas trocar seu texto.

## Comportamento

- No Speed Run, pegar uma opção diferente da pedida mantém o personagem correndo. Não há aviso visual ou falado de erro, pergunta, pausa ou retorno. A atividade fica para trás sem contar como acerto.
- Deixar opções passarem também mantém a corrida, sem gastar corações ou registrar erro.
- Na aventura manual, erros não mostram aviso nem abrem menus; a criança pode continuar se movimentando e escolher novamente por conta própria.
- Uma escolha errada ainda reduz o contador discreto de corações, conforme o pedido anterior da família. Ao esgotar, os três corações são renovados automaticamente, sem interromper a partida nem apagar descobertas, ponto de retorno ou poderes.
- Os acertos continuam com suas comemorações. O final da corrida continua acessível mesmo sem todas as descobertas. Só acertos reais entram na contagem, e só a coleta completa entra na comparação dos recordes pessoais.

A mudança se aplica também ao carregamento de uma aventura antiga com zero corações: ela retoma diretamente, com os acertos e poderes preservados. Nenhuma tela de nova tentativa é exibida.

As pausas voluntárias e as de proteção por perda de foco ou conexão do sensor continuam. Quedas ainda retornam ao ponto seguro sem apagar acertos. Iniciar outra corrida continua sendo uma escolha voluntária no menu ou após a chegada.

## Verificação

Foram aprovadas [25 verificações específicas](../evidence/uninterrupted-flow-tests.json), incluindo escolhas erradas consecutivas, corações esgotados, movimento contínuo real, ausência de menu e mensagem de erro, manutenção do tempo, acertos, poderes e ponto de retorno, carregamento de salvamento antigo e comemorações de acerto.

Também passaram [85 verificações de vidas e corrida](../evidence/lives-autorun-tests.json), incluindo as 68 fases completas com saltos, [38 de cronômetro e recordes](../evidence/speedrun-tests.json) e [100 gerais](../evidence/acceptance.json). Os testes usam perfis separados dos perfis da família.

O pacote entregue é a versão 0.8.0. [Verificação do pacote](../evidence/pack-verification-v08.json) · [Versão e hash](../release/verification.json). A versão anterior foi preservada em `release/Aventura-v0.7.pck`. O sensor físico continua pendente de validação com a família; nenhum novo asset ou conteúdo pedagógico foi alterado.
