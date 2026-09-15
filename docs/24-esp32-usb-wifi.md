# ESP32: bancada por USB e jogo por Wi-Fi

8 de setembro de 2026. Complemento externo ao jogo 0.12.0; não exige publicar o aplicativo.

## Estado real

Foi informado **ESP32-S**. Esse texto não foi interpretado automaticamente como ESP32-S3. Ainda precisamos de foto legível da placa e do módulo do sensor para confirmar modelo, alimentação e pinos. O firmware abaixo pressupõe MPU-9250 e exige a identificação interna 0x71; outro sensor requer adaptação. Nenhum ESP32 apareceu entre as portas USB do Mac nesta sessão.

Foram criados:

- `firmware/aventura_esp32/aventura_esp32.ino`: leitura do acelerômetro e giroscópio a 100 Hz, transmissão por USB ou UDP/Wi-Fi, identificação do dispositivo e nova sessão ao ligar. O magnetômetro não é necessário para este detector.
- `firmware/aventura_esp32/config.example.h`: modelo sem credenciais e sem pinagem presumida. Não compila enquanto os pinos não forem preenchidos no arquivo local `config.h`.
- `tools/imu_detector.py`: detector experimental no Mac, calibração com três segundos de dados estáveis, sequência impulso/alívio de peso e bloqueio de saltos duplicados.
- `tools/esp32_receiver.py`: recebe amostras por USB ou Wi-Fi e envia os comandos ao receptor local já existente no jogo.
- `tools/prepare_esp32.py`: prepara os arquivos locais de configuração, sem instalar, compilar ou gravar a placa.
- `Conectar sensor Wi-Fi.command`: atalho para iniciar o receptor depois da configuração.

**O firmware foi escrito, mas ainda não foi compilado com a ferramenta do ESP32 nem gravado/testado na placa física.** O detector não está validado para movimentos reais das crianças. Testes sintéticos não demonstram precisão, conforto ou latência do conjunto real.

## Conexão

MPU-9250 → ESP32 → USB ou rede Wi-Fi local → receptor/detector no Mac → jogo.

O computador continua executando o jogo e reconhecendo o gesto, inclusive no modo sem fio. O ESP32 envia as medidas brutas. Isso permite ajustar a detecção sem regravar a placa a cada ajuste.

## Primeira etapa: USB em bancada

1. Confirmar os módulos por foto e reaproveitar a ligação do projeto dos carros somente após conferir seus pinos/alimentação. Não interpretar exemplos de GPIO21/22 como pinagem universal do ESP32-S.
2. Conectar o ESP32 ao Mac com cabo USB de dados. O teste inicial com cabo é em bancada, fora do corpo.
3. Configurar Arduino IDE com o pacote oficial Espressif e selecionar o modelo real de placa. Abrir `firmware/aventura_esp32/aventura_esp32.ino`.
4. Na pasta do projeto, executar `python3 tools/prepare_esp32.py --sda GPIO_CONFIRMADO --scl GPIO_CONFIRMADO`, substituindo os dois marcadores por números confirmados. O programa cria `config.h` e uma chave local. Não há Wi-Fi nesta primeira configuração.
5. Compilar e gravar o sketch. Manter o monitor serial fechado ao iniciar o receptor, para não disputar a porta.
6. Para USB, preparar dependências isoladas: `python3 -m venv tools/.sensor-venv` e `tools/.sensor-venv/bin/python -m pip install pyserial`.
7. Executar `tools/.sensor-venv/bin/python tools/esp32_receiver.py --usb /dev/cu.PORTA_REAL --token-file firmware/local/pairing-token.txt`, trocando a porta pela do ESP32. A velocidade serial é 230400.
8. Abrir o jogo, escolher **Com sensor**, deixar o aparelho parado por três segundos e entrar quando estiver pronto. Registrar e ajustar os gestos primeiro com um adulto. Uma queda ou um pico isolado não devem ser considerados um salto por si só.

Esses comandos são instruções de preparação; não foram executados para instalar ferramentas, gravar hardware ou alterar a rede nesta sessão.

## Segunda etapa: Wi-Fi sem fio

1. Usar uma rede Wi-Fi compatível com o modelo confirmado do ESP32 e permitir comunicação local entre ele e o Mac. O Mac pode usar outra faixa de rádio do mesmo roteador, desde que ambos estejam na mesma rede local sem isolamento de clientes.
2. Obter o IPv4 do Mac nos detalhes da conexão de rede. Reservar esse endereço no roteador evita reconfiguração caso ele mude.
3. Reexecutar o preparador com os pinos confirmados, acrescentando `--wifi --mac-ip IP_DO_MAC`. Ele solicita o nome e a senha da rede no terminal local. A senha não precisa ser enviada pela conversa. A chave existente é reaproveitada.
4. Recompilar e gravar o ESP32 ainda pelo cabo; depois usar alimentação portátil apropriada ao módulo, com conexões protegidas, antes do teste sem fio.
5. Abrir **Conectar sensor Wi-Fi.command** e, no jogo, **Com sensor**. Se o macOS solicitar permissão para o receptor receber conexões locais, permitir para esse teste na rede doméstica. Não abrir portas do roteador para a internet.
6. Calibrar e testar. No Speed Run, a corrida é automática; para combinar os modos, abrir Speed Run, selecionar a fase, pausar e escolher **Conectar sensor**. O salto passa a vir do movimento e os poderes continuam disponíveis nos botões.

No modo Wi-Fi, o receptor usa apenas a biblioteca padrão do Python, sem pyserial. O jogo não precisa de nova exportação: o protocolo local é o mesmo. Ao terminar, Ctrl+C encerra o receptor. A ausência de amostras deixa o jogo detectar a desconexão e oferecer a continuação pelos botões.

## Protocolo e limites

UDP na rede local: porta 9251 no Mac. Encaminhamento ao jogo: `127.0.0.1:9250`. A porta 9252 é a origem do ESP32. O firmware envia JSON versão 1 com token, identificador, sessão de inicialização, sequência, milissegundos desde a inicialização, aceleração em g e rotação em graus/s. Os registros do MPU foram configurados para ±4g e ±500 graus/s.

O receptor rejeita chave errada, outro emissor durante a sessão, amostras malformadas, duplicatas e atrasos relativos superiores a 150 ms. A chave é um pareamento simples de rede doméstica; o UDP não é criptografado. Os arquivos `config.h` e `firmware/local/` contêm configuração privada e não devem ser compartilhados.

Critérios iniciais do detector: repouso próximo de 1g, pouca rotação por três segundos; impulso acima de 1,4 vezes o repouso seguido por magnitude abaixo de 0,72 por pelo menos 25 ms, dentro de 350 ms; intervalo de 650 ms entre eventos. São hipóteses de bancada ajustáveis, não parâmetros validados para crianças. Caminhar, correr, agachar, girar, bater no aparelho e saltar precisam ser registrados no hardware real para medir falsos positivos e saltos perdidos. O posicionamento corporal e a fixação afetam bastante o resultado.

## Evidência

13 testes automatizados do detector/receptor passaram com sinais sintéticos. O teste `tools/test_esp32_integration.py` exercita a recepção UDP de medidas simuladas, reconhecimento do salto, transmissão local ao Godot e desconexão quando o envio de medidas para, mantendo o receptor em execução. O resultado fica em `evidence/esp32-integration.json`.

## Referências consultadas

- [Espressif: I²C no Arduino ESP32](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/i2c.html), documentação oficial consultada por Context7.
- [TDK: mapa de registros MPU-9250](https://invensense.tdk.com/wp-content/uploads/2015/02/RM-MPU-9250A-00-v1.6.pdf).

## Identificação por fotos — 11 de setembro de 2026

As fotos IMG_6103 e IMG_6102 mostram uma placa com inscrição **NodeMCU ESP-32S**, revisão impressa V1.1, conector USB-C e botões EN e IO0. A inscrição do módulo é ESP-32. Não foi identificada como ESP32-S3. Há pinos serigrafados P21 e P22; a ligação definitiva depende também da identificação do módulo MPU quando disponível. Prévias das fotos foram guardadas em `references/hardware/`.

Na consulta USB ao Mac, apareceu apenas um USB2.0 Hub (VID 0x05e3, PID 0x0608); não apareceu conversor USB-serial da placa. As únicas portas eram `cu.debug-console` e `cu.Bluetooth-Incoming-Port`. Não foi possível iniciar comunicação nem gravar firmware. Próximo passo: conferir conexão, testar cabo USB de dados e preferir conexão direta ou outro adaptador/porta. A causa da ausência de detecção ainda não foi determinada. Nenhum driver foi instalado e nenhum firmware foi gravado.

## Reconexão bem-sucedida — 11 de setembro de 2026

Após a reconexão, o Mac reconheceu **CP2102 USB to UART Bridge Controller**, VID 0x10c4/PID 0xea60, e criou `/dev/cu.usbserial-0001`. A leitura pela ferramenta oficial esptool 5.4.0 confirmou **ESP32-D0WD-V3, revisão v3.1, flash de 4 MB e cristal de 40 MHz**. Portanto o chip é ESP32 clássico, e não S3.

A comunicação de programação por USB foi confirmada. `esptool` e `pyserial` foram instalados em `tools/.sensor-venv`, isolados no projeto. A operação executada foi `flash-id`: houve carregamento temporário do auxiliar em RAM e reinício da placa, sem apagar ou gravar a memória flash. O programa persistente anterior foi preservado. Evidência: `evidence/esp32-identification.json`. O MPU ainda não estava conectado, e a compilação/gravação do firmware do jogo permanece pendente.

## Ligações propostas para iniciante — aguardando foto do MPU

Na NodeMCU ESP-32S identificada, usar **P21/GPIO21 para SDA** e **P22/GPIO22 para SCL**, além de GND comum. P21 é a inscrição do pino, não o 21º contato da placa. A configuração do firmware deve acompanhar esses números.

Antes de montar, retirar o cabo USB e qualquer outra alimentação. A entrada de alimentação do módulo MPU ainda não foi identificada: confirmar por fotos frente/verso e documentação do módulo se recebe 3,3 V e qual pino utilizar. Não ligar em 5V/VIN por suposição. O chip MPU-9250 especifica VDD de 2,4–3,6 V; módulos podem acrescentar regulador e conexões adicionais (por exemplo CS/AD0). A orientação definitiva de alimentação e eventuais pinos extras depende do módulo real.

Fonte de GPIO: [Espressif, I²C](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/i2c.html). Fonte de alimentação do chip: [TDK, MPU-9250](https://product.tdk.com/system/files/dam/doc/product/sensor/mortion-inertial/imu/data_sheet/ps-mpu-9250a-01-v1.1.pdf).

## Foto do módulo recebida — IMG_6105, 11 de setembro de 2026

A serigrafia do módulo é **MPU-9250/6500**. Os pinos legíveis, de cima para baixo na foto, são VCC, GND, SCL, SDA, EDA, ECL, AD0 (impresso como ADO), INT, NCS e FSYNC. A serigrafia compartilhada não confirma se o chip é 9250 ou 6500; confirmar eletronicamente antes de concluir compatibilidade com o firmware, que atualmente exige WHO_AM_I 0x71.

Esquema preliminar em I²C, ainda não liberado para energizar e sempre montado com USB/bateria removidos: VCC em 3V3 é uma hipótese a confirmar pelo regulador/jumper do módulo; GND para GND; SCL para P22; SDA para P21; NCS mantido alto em 3,3 V; AD0 e FSYNC em GND. EDA/ECL/INT ficam livres neste uso. Alguns módulos já estabelecem os estados de NCS/AD0/FSYNC por resistores, mas não presumimos seu funcionamento só pela aparência. Não usar 5V/VIN.

Na protoboard, distribuir 3V3 por um segmento do trilho positivo para VCC/NCS, e GND por um segmento do trilho negativo para GND/AD0/FSYNC. As cores das linhas são apenas marcações: esses trilhos só recebem alimentação após serem ligados à ESP32. Trilhos separados/interrompidos não são necessariamente conectados entre si. Usar o mesmo segmento em cada grupo e não deixar fios desencapados se tocarem. A posição dos furos e as outras pontas dos fios ainda não foram verificadas; pedir foto do conjunto antes de energizar.

Referência da foto: `references/hardware/mpu-9250-6500-frente.png`. Sem instalação/gravação de firmware nesta etapa.

**Ressalva após consulta da documentação de módulos:** a foto recebida mostra somente a frente e não confirma a faixa de entrada VCC do módulo. Um módulo semelhante [Addicore AD280](https://www.addicore.com/products/mpu-9250-9-dof-3-axis-accelerometer-gyro-magnetometer) especifica 4,4–6,5 V antes do regulador ou 3,3 V com jumper soldado. Não assumir que a placa fotografada seja esse produto ou tenha o mesmo circuito. Solicitar verso e, se possível, procedência do módulo antes de definir alimentação ou orientar alteração de jumper. A tabela de comunicação GND/SCL/SDA já está definida; não orientar ligação a 5 V por semelhança visual.
