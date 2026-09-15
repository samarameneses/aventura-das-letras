# Aventura contínua e oito superpoderes — 0.9.0

A família pediu uma brincadeira mais longa, sem a tela de conclusão aparecendo a cada grupo curto de atividades, e todos os oito poderes sugeridos.

## Duração

O padrão passa a ser **contínua — até você pausar**. Os 68 trechos continuam organizados em grupos curtos para guardar as descobertas, mas são jogados em sequência: o portal leva diretamente ao próximo trecho e cenário, sem pergunta ou tela de conclusão. Há uma troca de cenário entre os trechos; não é um único mapa físico sem emendas.

O cronômetro total do Speed Run, a contagem de descobertas da sessão, os corações, os efeitos ativos e a recarga dos poderes seguem para o próximo trecho. Depois da última etapa, a trilha volta ao alfabeto, sem exigir uma escolha no menu. Na aventura manual, o trecho é salvo como concluído após as descobertas; no Speed Run, deixar opções passarem continua permitido.

Em **Poderes e duração**, no menu ou na pausa, o botão de duração alterna entre contínua e uma fase por vez. A segunda opção mantém a tela de conclusão ao final do trecho. Esc pausa em ambos os modos. O comprimento individual dos trechos foi preservado; a duração maior vem da ligação automática entre eles, sem alongar os espaços vazios.

## Oito poderes disponíveis

Todos os personagens podem usar todos os poderes. Escolha dois nos espaços **Poder 1** e **Poder 2**. A escolha fica salva por perfil e pode ser alterada na pausa, retomando do mesmo lugar. Escolher o poder do outro espaço troca os dois de lugar.

| Poder | Efeito | Duração | Recarga após o efeito |
| --- | --- | --- | --- |
| Supervelocidade | Acelera com rastro dourado; perto das opções mantém a velocidade habitual para facilitar a escolha. | 6 s | 10 s |
| Pulo duplo | A ativação dá um salto; quando ativado no chão, permite um segundo salto no ar. Durante o efeito, novos saltos a partir do chão também ganham um salto extra. | 8 s | 8 s |
| Asas mágicas | Dá impulso para cima e limita a velocidade de descida, permitindo planar. | 6 s | 10 s |
| Ímã das letras | Atrai apenas a opção pedida ao se aproximar; funciona também com sílabas e palavras. A descoberta é registrada com ajuda. | 6 s | 12 s |
| Bolha flutuante | Mantém o personagem flutuando para atravessar o vão. | 6 s | 12 s |
| Ponte de arco-íris | Cria uma plataforma sobre o vão. Se o tempo acabar enquanto o personagem estiver sobre ela, permanece até ele sair em segurança. | 8 s | 12 s |
| Tempo de tartaruga | Reduz pela metade a corrida no chão para observar as opções. Preserva a velocidade no ar necessária para atravessar o vão. | 8 s | 10 s |
| Luz das descobertas | Destaca a opção pedida e solicita sua pronúncia pela narração, sem coletá-la automaticamente. O acerto durante a ajuda é identificado como assistido. | 8 s | 10 s |

Os poderes estão prontos no início; não dependem de pegar um item. Efeito e recarga usam o tempo de jogo e param durante a pausa. O tênis existente no caminho recarrega os poderes. Mudar de poder na pausa não apaga sua recarga. Ao sair da partida, os efeitos temporários terminam; a seleção dos dois poderes permanece salva.

## Controles

- **Espaço / A no controle / botão Pular:** salto, incluindo o salto extra disponível.
- **E / X no controle / botão do primeiro poder:** Poder 1.
- **Q / B no controle / botão do segundo poder:** Poder 2.
- **Esc / Start:** pausa; acesso à seleção e à duração.

As teclas podem ser alteradas em Ajustes. Se Q já pertencia a uma tecla personalizada de um salvamento anterior, o segundo poder recebe outra tecla livre, mostrada na interface. O sensor continua acionando o salto e os poderes podem ser usados por botão. Não é necessário exigir dois saltos físicos rápidos para o pulo duplo.

## Experiência e progresso

Erros continuam sem aviso visual ou falado, pergunta de nova tentativa ou retorno obrigatório. Corações esgotados se renovam automaticamente. Acertos continuam com suas comemorações, e a instrução de cada atividade permanece no topo com narração opcional.

A aventura guarda as descobertas por trecho e perfil. Speed Run mantém seu progresso separado e seu tempo total enquanto a sessão está aberta; ao sair, a posição da corrida não é guardada. Os recordes por trecho exigem todas as descobertas reais daquele trecho. Os tempos com os novos poderes são armazenados separadamente dos recordes antigos, que permanecem preservados.

As imagens já geradas para personagens e cenários continuam sendo utilizadas. Os efeitos temporários dos poderes são formas e partículas desenhadas pelo jogo, com contornos e cores simples; não foram geradas novas imagens raster nesta atualização.

## Verificação

- [43 verificações de poderes e continuidade](../evidence/powers-continuity-tests.json): seleção, persistência, dois controles, recarga, pausa, física dos oito poderes, três trechos consecutivos jogados só com saltos, continuidade do tempo/efeitos/corações, volta ao alfabeto, progresso normal e opção de trecho único.
- [45 verificações da interface](../evidence/power-ui-tests.json) em uma janela real: seleção dos oito poderes, botões de ativação, efeitos em cena, pausa e configurações dentro da área visível.
- [85 verificações de vidas/corrida](../evidence/lives-autorun-tests.json), incluindo conclusão das 68 fases com saltos; [397 de conteúdo e cenários](../evidence/curriculum-tests.json); [101 verificações gerais](../evidence/acceptance.json); [38 de cronômetro/recordes](../evidence/speedrun-tests.json); [25 da experiência sem avisos de erro](../evidence/uninterrupted-flow-tests.json); [6 de pausa por foco](../evidence/window-focus-tests.json).
- [Verificação do pacote final](../evidence/pack-verification-v09.json) e [versão/hash](../release/verification.json).

Os testes usam perfis próprios, sem preencher as descobertas da família. Sensor e controle físicos ainda precisam de validação com a família.

Referências de implementação consultadas pelo Context7: [movimento CharacterBody2D](https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html) e [alterações de colisão adiadas](https://docs.godotengine.org/en/4.7/getting_started/first_2d_game/03.coding_the_player.html).

![Seleção dos oito poderes](../evidence/v09-oito-poderes.png)

![Bolha e asas durante o jogo](../evidence/v09-bolha-em-acao.png)
