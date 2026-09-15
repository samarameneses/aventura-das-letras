# Alfabeto, sílabas e comemorações — versão 0.2.0

> Atualização 0.4.0: agora são 48 fases, com 30 palavras monossílabas e cenários de primavera/outono. Veja [Palavras e estações](13-palavras-e-estacoes.md). Os números abaixo registram a entrega anterior.

Atualização solicitada pela família em 7 de setembro de 2026, implementada no jogo existente.

## O que mudou

O jogo agora oferece **42 fases e 202 atividades**: 26 letras do alfabeto, 169 combinações silábicas, três atividades de K/W/Y em nomes e as quatro descobertas da fase original. Cada fase tem entre duas e seis escolhas, com seu próprio ponto de retorno, respostas e poder coletado. O cenário e os personagens existentes foram reaproveitados; a mudança amplia o conteúdo e o funcionamento das fases.

A sequência recomendada começa em A–E, segue F–J, K–O, P–T e U–Z e continua com BA, BE, BI, BO, BU. Ao concluir uma fase, **Próxima fase** abre a seguinte. **Escolher fase** permite praticar qualquer família sem ter de repetir todas as anteriores; o mapa registra as fases já concluídas. Os mesmos conteúdos estão disponíveis com teclado, controle ou sensor opcional.

## Conteúdo em português

As famílias com consoante e vogal são uma forma de organizar atividades iniciais, mas não representam todas as estruturas silábicas do português. A língua também tem sílabas com outras estruturas. Esta entrega cobre o conjunto listado abaixo, não todas as sílabas possíveis nem todas as regras de leitura de palavras. Referências: [Método silábico — CEALE/UFMG](https://ceale.fae.ufmg.br/glossarioceale/verbetes/metodo-silabico) e [Sílaba — CEALE/UFMG](https://ceale.fae.ufmg.br/glossarioceale/verbetes/silaba).

- Famílias iniciais: B, C, D, F, G, J, L, M, N, P, R, S, T, V, X e Z, combinadas com A, E, I, O e U.
- Casos especiais: QUA/QUE/QUI/QUO; HA/HE/HI/HO/HU com H inicial silencioso; ÇA/ÇO/ÇU; GUE/GUI com palavras de apoio.
- Dígrafos: CHA/CHE/CHI/CHO/CHU, LHA/LHE/LHI/LHO/LHU, NHA/NHE/NHI/NHO/NHU.
- Encontros consonantais: BL, BR, CL, CR, DR, FL, FR, GL, GR, PL, PR e TR com as cinco vogais.
- K, W e Y aparecem nas 26 letras e em nomes como Kátia, William e Yuri. Não foram inventadas famílias regulares de W ou Y: a pronúncia depende da origem e do contexto. [Academia Brasileira de Letras](https://www.academia.org.br/artigos/novas-letras-k-w-e-y).

Não há QA/QE/QI/QO apresentados como uma família regular; Ç não é contado como letra adicional. O uso de Ç e outras convenções exige contexto de palavra. [Convenções da escrita — CEALE/UFMG](https://ceale.fae.ufmg.br/glossarioceale/verbetes/convencoes-da-escrita).

Cada combinação traz uma palavra de apoio quando disponível, inclusive no interior de palavras. NHU fica sem palavra de apoio, por ser raro, para não inventar vocabulário. O X foi trabalhado com o som de xale; outros sons de X, ditongos, sílabas terminadas em consoante, nasalização e o restante das regras ortográficas não estão esgotados nesta entrega.

As letras e sílabas são texto real, com tamanhos adaptados a uma, duas ou três letras. As opções continuam dentro dos suportes pixelados. A instrução apresenta o alvo por escrito e por voz; trata-se de reconhecimento com apoio, não de um teste de leitura sem pistas.

## Comemoração de cada acerto

Um acerto válido mostra uma faixa dourada por aproximadamente 3,4 segundos, identifica a letra/sílaba encontrada e sua palavra de apoio e aciona a comemoração do personagem ao pousar. A criança pode continuar andando normalmente. As frases também são narradas quando a voz está ativada:

1. Isso, você acertou!!!
2. Muito bem! Você conseguiu!
3. Uhu! Você encontrou!
4. Boa descoberta! Vamos continuar!
5. Que legal! Mais uma conquista!
6. Parabéns! Você está aprendendo!
7. Mandou bem! Vamos para a próxima!
8. Isso mesmo! Continue explorando!

As frases são embaralhadas em grupos: todas aparecem antes de começar um novo grupo, e a última de um grupo não se repete imediatamente no seguinte. Coletar uma resposta já concluída não gera nova comemoração ou novo registro. Uma resposta diferente do alvo convida a tentar novamente, sem punição, comparação ou perda de progresso. Quedas permanecem registradas como eventos de movimento, separadas das respostas.

## Progresso e atualização

O salvamento passou à versão 2. Perfis, personagens, histórico de tentativas e configurações são preservados. A fase original continua em **Especiais → Jardim das primeiras descobertas**. Se havia uma partida antiga em andamento, ela continua selecionada no ponto salvo; o novo alfabeto pode ser aberto pelo mapa.

Antes da primeira gravação migrada, o jogo preserva o arquivo anterior em `progress.json.v1.bak`. O backup normal `.bak` continua disponível. Repetir uma fase reinicia somente aquela partida; não apaga as descobertas de outras fases nem o histórico do perfil.

## Validação

- `evidence/curriculum-tests.json`: 173 verificações aprovadas, incluindo percurso físico das 42 fases, encaixe dos textos, reforço sem repetição, isolamento do progresso e migração de arquivo v1.
- `evidence/acceptance-v02.log`: 100 verificações da fase original, personagens, controles, poder e protocolo do sensor aprovadas.
- `evidence/curriculum-ui.json`: rolagem acompanhando o foco do teclado e botão Próxima fase abrindo a família seguinte aprovados.
- `evidence/v02-*.png`: telas renderizadas de mapa, BA, BRA, comemoração e conclusão no Mac.

Os testes usaram comandos de entrada, física e renderização reais do motor. Não houve avaliação com criança, controle físico ou sensor físico. A narração usa a voz brasileira instalada no Mac; pronúncias isoladas e palavras menos frequentes ainda precisam de escuta de um adulto, pois a voz sintética e as variedades regionais podem produzir diferenças, especialmente em E/O, encontros consonantais e combinações raras. O conjunto é conteúdo inicial para prática em família, sem alegar avaliação pedagógica profissional ou eficácia medida.

Os dados editáveis ficam em `game/content/curriculum.json`; `tools/build_curriculum.py` os reproduz a partir da lista explícita. As imagens e os prompts anteriores permanecem preservados; nenhuma foto pessoal foi acrescentada ao pacote do jogo.

## Lista completa das fases

| Fase | Atividades |
| --- | --- |
| Alfabeto · A a E | A, B, C, D, E |
| Alfabeto · F a J | F, G, H, I, J |
| Alfabeto · K a O | K, L, M, N, O |
| Alfabeto · P a T | P, Q, R, S, T |
| Alfabeto · U a Z | U, V, W, X, Y, Z |
| Família B | BA, BE, BI, BO, BU |
| Família C | CA, CE, CI, CO, CU |
| Família D | DA, DE, DI, DO, DU |
| Família F | FA, FE, FI, FO, FU |
| Família G | GA, GE, GI, GO, GU |
| Família J | JA, JE, JI, JO, JU |
| Família L | LA, LE, LI, LO, LU |
| Família M | MA, ME, MI, MO, MU |
| Família N | NA, NE, NI, NO, NU |
| Família P | PA, PE, PI, PO, PU |
| Família R | RA, RE, RI, RO, RU |
| Família S | SA, SE, SI, SO, SU |
| Família T | TA, TE, TI, TO, TU |
| Família V | VA, VE, VI, VO, VU |
| Família X | XA, XE, XI, XO, XU |
| Família Z | ZA, ZE, ZI, ZO, ZU |
| QUA · QUE · QUI · QUO | QUA, QUE, QUI, QUO |
| Família H | HA, HE, HI, HO, HU |
| ÇA · ÇO · ÇU | ÇA, ÇO, ÇU |
| GUE · GUI | GUE, GUI |
| Família CH | CHA, CHE, CHI, CHO, CHU |
| Família LH | LHA, LHE, LHI, LHO, LHU |
| Família NH | NHA, NHE, NHI, NHO, NHU |
| Família BL | BLA, BLE, BLI, BLO, BLU |
| Família BR | BRA, BRE, BRI, BRO, BRU |
| Família CL | CLA, CLE, CLI, CLO, CLU |
| Família CR | CRA, CRE, CRI, CRO, CRU |
| Família DR | DRA, DRE, DRI, DRO, DRU |
| Família FL | FLA, FLE, FLI, FLO, FLU |
| Família FR | FRA, FRE, FRI, FRO, FRU |
| Família GL | GLA, GLE, GLI, GLO, GLU |
| Família GR | GRA, GRE, GRI, GRO, GRU |
| Família PL | PLA, PLE, PLI, PLO, PLU |
| Família PR | PRA, PRE, PRI, PRO, PRU |
| Família TR | TRA, TRE, TRI, TRO, TRU |
| K, W e Y nos nomes | K, W, Y |
| Jardim das primeiras descobertas | A, M, L, 3 |
