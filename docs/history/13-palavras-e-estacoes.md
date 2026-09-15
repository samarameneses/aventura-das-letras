# Palavras monossílabas e estações — versão 0.4.0

> A versão 0.5.0 acrescenta 100 dissílabas: agora são 68 fases. Veja [100 palavras dissílabas](14-cem-palavras-dissilabas.md). Esta página registra a entrega 0.4.0.

Entrega de 7 de setembro de 2026. As fases de palavras monossílabas foram implementadas nesta atualização; anteriormente havia letras, sílabas e a fase original de quantidade.

## Como acessar

Abra **Aventura das Letras.app → Escolher fase → Palavras**. Para uma corrida cronometrada, use **Speed Run → Palavras**. O botão **Próxima fase** avança automaticamente para o conteúdo seguinte e troca o cenário. Também é possível entrar diretamente em qualquer fase pelo mapa, sem precisar concluir as anteriores.

## Seis fases, 30 palavras

| Fase | Palavras | Cenário |
| --- | --- | --- |
| Palavras · Natureza | SOL, MAR, LUZ, SOM, COR | Outono · Bosque acolhedor |
| Palavras · Dia a dia | PÉ, MÃO, PÃO, MEL, SAL | Primavera · Lago encantado |
| Palavras · Bichos e jardim | BOI, CÃO, RÃ, LÃ, FLOR | Outono · Vale encantado |
| Palavras · Descobertas | CÉU, REI, PAI, MÃE, TREM | Primavera · Caminho das flores |
| Palavras · Pequenas palavras | CHÁ, PÓ, NÓ, PÁ, GIZ | Outono · Passeio dourado |
| Palavras · Mais conquistas | PAZ, VOZ, GOL, BEM, SIM | Primavera · Passeio à beira-lago |

As palavras têm uma única sílaba falada. A contagem não corresponde ao número de letras: FLOR e TREM, por exemplo, continuam sendo monossílabas. Os acentos de PÉ, PÃO, MÃE, CÉU e demais palavras foram preservados no texto e na narração. Não foram incluídas LUA ou RIO como monossílabas.

O jogo pede uma palavra, apresenta duas opções escritas e permite coletar a escolha pulando. Os suportes são maiores para palavras; textos de quatro letras usam tamanho ajustado para caber dentro da moldura. O conteúdo continua sendo texto real, sem letras desenhadas dentro das imagens.

Cada acerto usa as oito frases de reforço positivo já existentes, sem repetição imediata, além da faixa de comemoração e da animação do personagem. A narração depende da voz em português instalada e da opção de voz ativada. Esta atividade trabalha reconhecimento com apoio visual e oral; não mede, sozinha, leitura autônoma ou compreensão. A definição de uma sílaba falada e a distinção entre extensão escrita e estrutura silábica seguem a explicação do [CEALE/UFMG sobre sílaba](https://ceale.fae.ufmg.br/glossarioceale/verbetes/silaba).

## Cenários por fase

Foram gerados quatro panoramas originais em pixel art com a ferramenta integrada de imagens do ChatGPT:

- **Primavera — pomar:** flores rosadas e brancas, riacho e colinas verdes.
- **Primavera — lago:** águas azuis, cachoeira e árvores lilases.
- **Outono — bosque:** folhas em laranja, cobre e dourado, com cabana distante.
- **Outono — vale:** campos dourados, moinho e céu de pôr do sol.

As 48 fases usam **48 composições distintas desses quatro panoramas**, com enquadramento, orientação e variação suave de cores. Não são 48 imagens geradas individualmente. A sequência alterna um template de primavera com um de outono, e cada cenário tem um nome no mapa. Ao repetir uma fase, sua composição permanece a mesma, inclusive em Speed Run. Os cenários são decorativos: altura do salto, posições das escolhas, plataformas, pontos de retorno e regras do cronômetro foram preservados.

Os PNGs originais foram copiados sem edição e continuam em [assets/backgrounds](../../assets/backgrounds). A composição é feita pelo jogo; não foram criadas cópias rasterizadas para cada enquadramento. Os prompts completos, referências e destinos estão em production/seasons-jobs.json — registro local não distribuído (`production/seasons-jobs.json`) e [production/prompts](../../production/prompts). A procedência e os hashes estão em [assets/manifest.json](../../assets/manifest.json). A ferramenta utilizada foi **image_gen integrada**, sem CLI/API externa; ela não expõe o identificador do modelo, portanto a versão solicitada “ChatGPT Image 2.5” não foi tecnicamente confirmada.

| ID estável | Fase | Fundo |
| --- | --- | --- |
| alfabeto_01 | Alfabeto · A a E | Primavera · Pomar florido |
| alfabeto_02 | Alfabeto · F a J | Outono · Bosque dourado |
| alfabeto_03 | Alfabeto · K a O | Primavera · Lago das flores |
| alfabeto_04 | Alfabeto · P a T | Outono · Vale do pôr do sol |
| alfabeto_05 | Alfabeto · U a Z | Primavera · Cerejeiras |
| silabas_b | Família B | Outono · Folhas de cobre |
| silabas_c | Família C | Primavera · Cachoeira |
| silabas_d | Família D | Outono · Moinho distante |
| silabas_f | Família F | Primavera · Jardim das maçãs |
| silabas_g | Família G | Outono · Clareira âmbar |
| silabas_j | Família J | Primavera · Margem florida |
| silabas_l | Família L | Outono · Campos dourados |
| silabas_m | Família M | Primavera · Flores ao vento |
| silabas_n | Família N | Outono · Cabaninha |
| silabas_p | Família P | Primavera · Espelho azul |
| silabas_r | Família R | Outono · Colinas de cobre |
| silabas_s | Família S | Primavera · Colinas verdes |
| silabas_t | Família T | Outono · Colinas de outono |
| silabas_v | Família V | Primavera · Jardim lilás |
| silabas_x | Família X | Outono · Árvores vermelhas |
| silabas_z | Família Z | Primavera · Ponte das flores |
| silabas_quaquequiquo | QUA · QUE · QUI · QUO | Outono · Trilha das folhas |
| silabas_h | Família H | Primavera · Águas tranquilas |
| silabas_cedilhaacedilhaocedilhau | ÇA · ÇO · ÇU | Outono · Horizonte coral |
| silabas_guegui | GUE · GUI | Primavera · Pétalas rosadas |
| silabas_ch | Família CH | Outono · Árvores douradas |
| silabas_lh | Família LH | Primavera · Flores na margem |
| silabas_nh | Família NH | Outono · Vale tranquilo |
| silabas_bl | Família BL | Primavera · Recanto verde |
| silabas_br | Família BR | Outono · Refúgio do bosque |
| silabas_cl | Família CL | Primavera · Refúgio azul |
| silabas_cr | Família CR | Outono · Luz entre colinas |
| silabas_dr | Família DR | Primavera · Trilha perfumada |
| silabas_fl | Família FL | Outono · Luz dourada |
| silabas_fr | Família FR | Primavera · Colinas do lago |
| silabas_gl | Família GL | Outono · Trilha dos campos |
| silabas_gr | Família GR | Primavera · Sol entre flores |
| silabas_pl | Família PL | Outono · Recanto de outono |
| silabas_pr | Família PR | Primavera · Brisa no lago |
| silabas_tr | Família TR | Outono · Brisa de outono |
| nomes_kwy | K, W e Y nos nomes | Primavera · Pomar encantado |
| palavras_01 | Palavras · Natureza | Outono · Bosque acolhedor |
| palavras_02 | Palavras · Dia a dia | Primavera · Lago encantado |
| palavras_03 | Palavras · Bichos e jardim | Outono · Vale encantado |
| palavras_04 | Palavras · Descobertas | Primavera · Caminho das flores |
| palavras_05 | Palavras · Pequenas palavras | Outono · Passeio dourado |
| palavras_06 | Palavras · Mais conquistas | Primavera · Passeio à beira-lago |
| jardim_inicio | Jardim das primeiras descobertas | Outono · Fim de tarde |

## Progresso e controles

O total passa de 42 fases/202 atividades para **48 fases/232 atividades**: 26 letras, 169 combinações silábicas, 30 palavras, três atividades de K/W/Y e quatro atividades da fase original. Os IDs antigos e o formato de salvamento v2 foram mantidos. A migração do formato v1 e sua cópia de segurança continuam disponíveis.

O progresso segue separado por fase e perfil. As palavras entram depois de K/W/Y na sequência; o Jardim das primeiras descobertas continua acessível em Especiais. Os quatro personagens e os controles sem sensor funcionam em todas as fases. O sensor continua opcional, com comunicação simulada testada; a leitura do gesto físico depende do hardware da família.

## Verificação

- **292 verificações de currículo e cenários:** percurso físico por todas as 48 fases, 232 coletas por saltos, chegada ao portal, textos dentro dos limites, 48 composições únicas, recortes dentro das imagens, troca de template entre fases, grafia das palavras, navegação, salvamento e migração. Relatório — registro local não distribuído (`evidence/curriculum-tests.json`).
- **100 verificações de regressão:** quatro personagens, movimentos, quedas, poderes, pausa, salvamento e conexão local simulada. Relatório — registro local não distribuído (`evidence/acceptance.json`).
- **42 verificações de Speed Run:** cronômetro, pausas, conclusão, recordes e separação da aventura. Relatório — registro local não distribuído (`evidence/speedrun-tests.json`).
- **Verificação visual no Mac:** menu Palavras, troca efetiva pelo botão Próxima fase, os quatro templates, acentos, FLOR/TREM, comemoração e corrida com palavras. Relatório — registro local não distribuído (`evidence/words-ui.json`).

Capturas de exemplo: outono com SOL — registro local não distribuído (`evidence/v04-outono-bosque-sol.png`), primavera com PÉ — registro local não distribuído (`evidence/v04-primavera-lago-pe.png`), pomar com TREM — registro local não distribuído (`evidence/v04-primavera-pomar-trem.png`).

As capturas de resultado usam uma partida de teste separada para conferir a interface; os percursos completos com saltos são verificados no teste de currículo. Nenhum perfil da família recebe as conquistas de teste. A validação com as crianças, o controle físico e o sensor físico ainda não foi realizada.

O pacote exportado 0.4.0 também foi aberto e validado: quatro personagens com todas as animações, 48 fases, palavras acentuadas, quatro panoramas, cronômetro e gravação de progresso. Verificação do pacote — registro local não distribuído (`evidence/pack-verification-v04.json`) · Versão e hash — registro local não distribuído (`release/verification.json`). O pacote anterior foi preservado em `release/Aventura-v0.3.pck`.
