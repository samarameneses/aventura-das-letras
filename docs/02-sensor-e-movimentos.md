# Sensor opcional e movimentos no jogo 2D

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


## Resposta direta

**Sim, é tecnicamente plausível usar o sensor existente para transformar um salto físico em um comando no jogo.** Precisamos confirmar se é o MPU-9250 e testar o conjunto real antes de afirmar que terá boa precisão com as crianças.

O MPU-9250 reúne acelerômetro, giroscópio e magnetômetro de três eixos, com comunicação I²C/SPI. Ele mede sinais físicos; o programa identifica padrões e decide quando enviar “pular”. O sensor sozinho não inclui a placa que executa esse programa ou a comunicação sem fio. [TDK — especificação do MPU-9250](https://invensense.tdk.com/wp-content/uploads/2015/02/PS-MPU-9250A-01-v1.1.pdf).

## Modo sem sensor é completo

O jogo de plataforma 2D funciona integralmente sem hardware corporal: teclado ou controle permitem andar para esquerda/direita, saltar, ativar poderes, navegar pelos menus e concluir todas as fases com João Miguel, Luna, Lucas o Engenheiro ou Samara. Não exigir receptor instalado, conexão, permissões ou calibração. Não reservar recompensas ao modo corporal.

O sensor é um complemento opcional para acionar o mesmo salto. A direção continua por teclado/controle ou avanço assistido. O modo Sem sensor é padrão inicial; o menu de pausa permite trocar preservando perfil, personagem, checkpoint e progresso. Sair do modo corporal cancela e ignora seus eventos. Entrar exige conexão e calibração.

Se a conexão cair no modo Com sensor, pausar e oferecer **Continuar sem sensor** ou reconectar. No modo Sem sensor, ausência ou desconexão do dispositivo não interfere no jogo. Botão e gesto coincidentes devem produzir uma única intenção de salto.

## O que um único sensor permite

| Intenção | Avaliação | Como usar |
| --- | --- | --- |
| Detectar um gesto de salto | Viável como hipótese de engenharia | Acelerômetro e giroscópio, calibração e classificador temporal |
| Detectar inclinação | Viável, sujeito a movimento e fixação | Comandos simples com zona neutra, depois de validar |
| Reconhecer passos no lugar | Possível, exige outro conjunto de testes | Recurso futuro; passos podem se confundir com saltos |
| Medir a altura exata do salto | Não necessária e não prometida | Altura virtual fixa |
| Saber a posição exata pela sala | Inadequado com esse sensor isolado | Usar comandos direcionais ou outra tecnologia de rastreamento |
| Reproduzir braços, pernas e tronco | Um sensor não observa o corpo inteiro | Animações prontas respondem ao comando |
| Detectar queda física com confiabilidade | Fora do escopo | Não apresentar o aparelho como dispositivo de proteção |

A estimativa de posição por integração de aceleração acumula erro. A documentação da Analog Devices descreve essa limitação e a necessidade de referências adicionais em navegação inercial. Isso fundamenta a decisão de usar **eventos de movimento**, sem tentar reproduzir o deslocamento real da criança no cômodo. [Analog Devices — navegação inercial](https://www.analog.com/en/resources/analog-dialogue/articles/strapdown-inertial-navigation-system-based-on-an-imu-and-a-geomagnetic-sensor.html).

## Montagem conceitual

```text
Sensor MPU-9250, se confirmado
          ↓ ligação curta dentro do dispositivo
Placa controladora existente ou placa compatível
          ↓ comunicação sem fio
Receptor no computador
          ↓ evento de salto
Jogo 2D → animação, física e coleta
```

Primeiro reaproveitar a placa e o programa do projeto de carros, se estiverem disponíveis. Precisamos saber o modelo da placa, como recebíamos os dados e se há código anterior. Não presumir que trocar a lógica de direção por salto será suficiente.

Se for necessário escolher uma placa nova, uma opção é ESP32 com Bluetooth LE. Confirmar o chip exato: a família tem capacidades diferentes; a documentação lista ESP32 com Bluetooth clássico e LE e ESP32-S3 com LE. Compatibilidade com o computador e autonomia ainda devem ser testadas. [Espressif — capacidades Bluetooth](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/bt-architecture/overview.html).

**Não há pinagem definitiva neste documento.** Tensão, regulador e tolerância dos pinos dependem do módulo usado. Identificar o módulo e consultar sua documentação antes de conectar alimentação. O nome MPU-9250 não prova que a placa aceite 5 V.

## Onde fixar

Minha hipótese inicial é uma pequena bolsa firme e acolchoada na cintura, sem ficar solta. Ela tende a acompanhar o tronco melhor que uma pulseira, que também mede movimentos livres do braço. Isso é uma escolha a testar, não uma conclusão validada para estas crianças.

Para uso corporal, o conjunto deve ficar fechado, com bordas arredondadas, bateria protegida e sem fios externos. Evitar pendurar no pescoço e fazer os primeiros testes com um adulto. Não usar cabo entre a criança e o computador durante saltos. Carregamento acontece fora do corpo. Manter espaço livre, piso estável e supervisão; oferecer botão e alternativa de gesto confortável desde o início.

Não há necessidade de a criança correr pela sala, saltar alto ou se aproximar da TV. O poder de velocidade acontece no jogo.

## Como reconhecer o salto

Este é um desenho de algoritmo, ainda sem implementação ou validação:

1. Coletar aceleração e velocidade angular com marcação de tempo consistente.
2. Calibrar a posição neutra, viés do giroscópio e nível de ruído com o dispositivo imóvel.
3. Registrar exemplos de movimento com um adulto: salto leve, caminhada, agachar, sentar, levantar e ajustar a bolsa.
4. Filtrar o ruído sem introduzir atraso excessivo. Estimar orientação com acelerômetro e giroscópio se for necessário separar a componente vertical. Não confiar no eixo vertical da placa se ela puder inclinar.
5. Procurar uma sequência temporal compatível com impulso de salto. Usar duração, intensidade relativa à calibração e rotação, em vez de apenas um pico de aceleração.
6. Emitir um único evento quando houver evidência suficiente no início do movimento.
7. Bloquear duplicatas durante a continuação do gesto e o pouso. Rearmar após recuperação do sinal e um intervalo mínimo.

Uma máquina de estados pode ser: `PRONTO → CANDIDATO → DISPARADO → RECUPERAÇÃO → PRONTO`. Um candidato sem evidência suficiente volta a `PRONTO` por tempo limite. Desconexão ou pausa cancela estados pendentes.

**Atenção à sensação de resposta:** esperar a criança terminar o salto e pousar para só então saltar no jogo cria atraso. Podemos usar o ciclo completo para confirmar registros e melhorar o detector, mas o comando jogável precisa acontecer mais cedo. O equilíbrio entre antecipação e falsos positivos será medido.

O magnetômetro não é requisito para o primeiro detector. Um pico de aceleração também pode representar uma batida no dispositivo. Um limiar único, como “acima de X, pular”, não basta para chamar a solução de confiável.

## Parâmetros iniciais para experimentar

Todos os números abaixo são **hipóteses de bancada**, não especificações comprovadas ou limites fisiológicos:

| Parâmetro | Ponto de partida | Validação |
| --- | --- | --- |
| Amostragem | Cerca de 100 Hz | Conferir frequência real, perdas e estabilidade |
| Calibração imóvel | Cerca de 3–5 s | Repetir quando a fixação mudar |
| Intervalo mínimo entre eventos | Cerca de 400–700 ms | Ajustar junto com o estado de recuperação |
| Ausência de mensagens | Cerca de 500 ms | Pausar modo corporal e cancelar movimento |
| Resposta perceptível | Buscar p95 abaixo de 150 ms | Medir do gesto escolhido como referência até a imagem na tela |

A latência inclui detecção, rádio, recepção, processamento do jogo e tela. TV com processamento de imagem pode acrescentar atraso. Não inferir latência completa comparando relógios do sensor e computador sem sincronização.

## Comunicação recomendada

Para a prova de conceito opcional do sensor, USB serve em bancada com o dispositivo fora do corpo. Para jogar, priorizar comunicação sem fio. Se a placa existente já envia dados por Wi-Fi, podemos reaproveitar isso e medir a resposta. Caso contrário, Bluetooth LE com um receptor local é uma opção.

O receptor converte os sinais em comandos que o jogo entende. Não presumir que o Godot terá suporte direto a qualquer dispositivo Bluetooth. Uma ponte local permite separar a integração de hardware do jogo.

Comportamentos obrigatórios: identificar a sessão, descartar eventos repetidos ou antigos, enviar sinal periódico de conexão, pausar quando o sensor desaparecer durante o modo corporal e exigir novo estado pronto após reconectar. Nunca reproduzir saltos acumulados durante uma interrupção.

## Como testar sem enganar a avaliação

Primeiro com adulto; depois, em rodadas curtas e supervisionadas com cada criança, se o conjunto estiver adequado. Não transformar a coleta de dados em uma série longa de saltos.

- Medir quantos gestos intencionais produzem exatamente um salto no jogo.
- Medir comandos falsos durante movimentos comuns, especialmente agachar, sentar, andar e mexer no dispositivo.
- Separar os exemplos usados para ajustar o detector dos exemplos usados para avaliar.
- Repetir em outro momento e depois de recolocar a bolsa.
- Testar desconexão, bateria baixa e retorno do aplicativo do segundo plano.
- Registrar atrasos típicos e piores casos, e não só a média.

Meta preliminar: reconhecer pelo menos 95% dos gestos intencionais de um conjunto de validação e ter no máximo um falso salto em cinco minutos de movimentos de controle. Amostras pequenas não demonstram confiabilidade geral. Se o comportamento frustrar a criança mesmo atingindo essa meta, o detector ainda não está pronto.

Se o sensor não atingir a qualidade necessária, manter o jogo funcionando por botão, revisar fixação e algoritmo e só então avaliar outro sensor ou outra modalidade de entrada. Isso evita perder todo o projeto por causa de um componente.

## Aceitação dos dois modos

Testar a fase completa sem dispositivo ou receptor, com cada personagem. Testar também conexão, calibração, perda de conexão, continuação por botão e troca de modo. O sensor não é pré-requisito para desenvolver, testar ou concluir o jogo convencional.
