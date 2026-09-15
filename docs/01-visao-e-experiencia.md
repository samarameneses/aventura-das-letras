# Visão e experiência do jogo 2D

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


## Proposta

**Aventura das Letras** é o nome provisório de um jogo de plataforma 2D inspirado nos jogos clássicos de plataforma em pixel art, com pixel art como direção visual obrigatória: visão lateral, caminhada para direita e esquerda, saltos, plataformas, itens, poderes e chegada ao final de cada fase. A arte será personalizada, com personagens baseados nas referências da família.

O objetivo educacional permanece: brincar com letras, sons, sílabas, palavras e quantidades, respeitando o repertório da criança. Pontuação e conclusão de fase não são prova de alfabetização.

## Personagens selecionáveis

| Nome exibido | Referência visual | Comportamento inicial |
| --- | --- | --- |
| João Miguel | Recebida; arte principal refeita em pixel art | Movimento, salto e poderes comuns ao elenco |
| Luna | Recebida; arte principal refeita em pixel art | Movimento, salto e poderes comuns ao elenco |
| Lucas o Engenheiro | Recebida; arte principal refeita em pixel art | Movimento, salto e poderes comuns ao elenco |
| Samara | Recebida; arte principal refeita em pixel art | Movimento, salto e poderes comuns ao elenco |

Os quatro estarão disponíveis na primeira versão completa, sem depender do sensor ou de desbloqueios. Um jogador por vez é a hipótese inicial. Escolher personagem é independente de escolher perfil de aprendizagem: a criança pode jogar com Lucas o Engenheiro ou Samara mantendo seu próprio progresso.

Roupas, idade visual e acessórios seguem as referências. Samara usa o look Nude Project enviado: moletom marrom com capuz, jeans claro largo e sapatos baixos escuros; a foto pessoal orienta seu rosto e cabelo. O título “o Engenheiro” não autoriza presumir capacete ou ferramentas. Proporções visuais podem variar, mas os quatro devem ter a mesma facilidade para atravessar a fase. Habilidades exclusivas ficam para decisão futura; nenhum personagem será necessário para acessar conteúdo educacional.

## Fluxo da partida

1. Escolher perfil e um dos quatro personagens. Menus têm nomes legíveis, retratos e apoio de voz.
2. Escolher **Sem sensor** ou **Com sensor**. Sem sensor é o padrão inicial.
3. Sem sensor, entrar diretamente no tutorial de botões. No modo corporal, conectar e calibrar; há sempre opção de continuar sem sensor.
4. Caminhar por um jardim lateral com chão firme, plataformas baixas e câmera que acompanha o percurso.
5. Ouvir “Encontre a letra A”. Ver duas alternativas espaçadas e escolher a posição antes de saltar.
6. Saltar por botão ou gesto físico para coletar a alternativa escolhida, com tolerância de alcance.
7. Receber feedback. Se o erro for de movimento ou sensor, ajudar sem registrar erro de leitura.
8. Ao cair em um vão virtual, retornar ao checkpoint, com velocidade zerada e sem perder o conteúdo já registrado.
9. Concluir poucas atividades, alcançar a recompensa e escolher repetir, continuar ou sair.

## Dois modos completos de controle

| Ação | Sem sensor | Com sensor |
| --- | --- | --- |
| Andar para esquerda/direita | Teclado ou direcional/analógico | Os mesmos controles; avanço assistido opcional |
| Saltar | Botão de salto | Gesto reconhecido ou botão de apoio |
| Ativar poder | Botão ou coleta do item | Os mesmos meios |
| Selecionar personagem e opções | Teclado ou controle | Teclado ou controle |
| Repetir instrução, pausar e retornar | Botões acessíveis | Os mesmos botões |
| Concluir fases e salvar progresso | Integralmente disponível | Integralmente disponível |

No teclado, propor A/D ou setas para direção, espaço para salto, E para poder, R para repetir instrução e Esc para pausa; tornar as ações remapeáveis. O esquema do controle deve corresponder ao dispositivo reconhecido. Toque em tela poderá entrar se celular ou tablet forem escolhidos; não está prometido na versão de computador.

**Avanço assistido é uma ajuda independente do modo de entrada.** Pode funcionar com botão ou sensor, andar lentamente e parar antes das decisões. Não deve levar à resposta correta automaticamente. O jogador ainda precisa escolher uma alternativa.

Trocar o modo pelo menu de pausa preserva personagem, perfil, checkpoint e progresso. Entrar no modo corporal exige calibração; sair cancela eventos do sensor e libera o jogo convencional. Se a conexão cair durante o modo corporal, pausar e oferecer **Continuar sem sensor**. Sensor desconectado não causa aviso ou pausa no modo sem sensor.

## Movimento, câmera e poderes

- Movimento horizontal responsivo; pulo e gravidade no eixo vertical. Recuar significa voltar pela fase para a esquerda, sem deslocamento em profundidade.
- Câmera lateral com limites de fase e acompanhamento suave, sem girar com o personagem ou tremer a cada salto.
- Salto inicial de altura padronizada nos dois modos, com tolerância para comandos próximos à saída de uma borda ou um pouco antes do pouso.
- Queda recuperável por checkpoint, sem vidas limitadas ou perda de aprendizagem no início.
- Velocidade aumenta apenas o movimento virtual por tempo curto e diminui perto das decisões de leitura.
- Salto mágico aumenta o alcance virtual pelo mesmo botão ou gesto.
- Ímã facilita alcançar a alternativa já escolhida; não escolhe a resposta correta.

Começar com movimento, salto, coleta e retorno; depois adicionar velocidade. Não exigir pular mais alto ou correr fisicamente para obter vantagens.

## Primeira fase: Jardim das Letras

Percurso horizontal curto com área de treinamento, três letras configuráveis, plataformas baixas, um vão de retorno seguro, checkpoint e chegada. O jogador precisa enxergar onde aterrissará. Colocar alternativas fora do fluxo de coleta automática para que atravessar a fase não seja confundido com responder.

Propor rodadas de aproximadamente três a cinco minutos, ajustáveis ao interesse e conforto. Isso é hipótese de experiência, não recomendação de exercício ou tempo de tela. Permitir pausa a qualquer momento e atividades sem prazo de resposta.

## Escopo da primeira versão completa

- Quatro personagens com retrato e animações de repouso, andar, correr, salto, queda, pouso e comemoração.
- Uma fase lateral bem acabada, com letras e uma demonstração de quantidades.
- Modos com e sem sensor, com igualdade de acesso a conteúdo e recompensas.
- Voz em português brasileiro, instruções visuais, controles remapeáveis e progresso local.
- Poder de velocidade após validar o movimento básico.

Evolução: novas fases, sílabas, palavras, frases, quantidades, poderes e eventual cooperação. A qualidade profissional será avaliada por consistência da arte, fluidez, precisão dos controles, legibilidade e ausência de bloqueios, começando em uma fase pequena.
