# Teste físico do MPU — 11 de setembro de 2026

## Preparação em andamento

ESP32-D0WD-V3, flash 4 MB, NodeMCU ESP-32S, porta `/dev/cu.usbserial-0001`. O usuário informou que conferiu a montagem e reconectou o conjunto por USB. As fotos das outras pontas dos fios e do verso do MPU não foram fornecidas; a ligação elétrica não foi validada visualmente pelo assistente.

O código `firmware/imu_diagnostic/imu_diagnostic.ino` testa I²C em GPIO21/SDA e GPIO22/SCL, a 100 kHz. Procura endereços que respondam, lê WHO_AM_I e só configura acelerômetro/giroscópio quando a identidade é compatível com MPU-6500 (0x70), MPU-9250 (0x71) ou MPU-9255 (0x73). Não envia comandos ao jogo nem acessa Wi-Fi. Relata dez amostras por segundo via USB, em 115200 baud. O firmware final de jogo ainda exige adaptação se a identidade não for 0x71.

A cópia de segurança da memória original precede a gravação do diagnóstico. Leituras em 921600 e 460800 falharam com erro de comunicação; pequenas leituras em 115200 e 230400 passaram. Não tratar isso como confirmação de defeito no sensor.

Ferramentas isoladas no projeto: esptool 5.4.0; Arduino CLI 1.5.2-rc.1. O core Espressif 2.0.17 foi escolhido para o diagnóstico sem rede do ESP32 clássico, por caber no espaço disponível; o índice atual também contém versões 3.x cujo conjunto completo de ferramentas exigiria mais armazenamento. Isso não é uma recomendação de versão para uma futura distribuição em rede.

## Preparação concluída e validação da cópia

O diagnóstico compilou: 278625 bytes de programa e 21744 bytes de variáveis globais. A instalação completa esgotou o espaço do Mac; foram removidos apenas downloads e ferramentas recém-instalados desta tentativa que não atendem ao ESP32 clássico. Mantidos compilador Xtensa ESP32 e SDK clássico, sem os SDKs S2/S3/C3. A instalação é parcial, destinada a esta placa. Os hooks locais de compilação foram ajustados para aceitar espaços no caminho do projeto.

A primeira leitura integral produziu 4194304 bytes, mas sua comparação posterior com a placa divergiu. A causa ainda não foi determinada; por isso ela não é tratada como cópia validada. Uma segunda leitura está sendo feita sem reiniciar o programa da placa entre leitura e conferência. Nenhum diagnóstico foi gravado até esta etapa.

## Cópia validada e gravação

A segunda leitura integral, `firmware/local/backups/esp32-original-20260911-stable.bin`, passou em `verify-flash` (digest correspondente à memória da placa). SHA-256: `69ef3e5fe20b3391bcfcd3369d9286d38a4942609c41ac3534153f8719aeffd5`. Arquivo privado, 4194304 bytes, fora do Git. As duas leituras diferem em 55 bytes no setor 0xA000; isso é compatível com dados alterados pelo programa original entre reinicializações, mas a causa não foi demonstrada.

O diagnóstico foi gravado em 230400 baud e os quatro segmentos passaram na verificação do esptool. A placa reiniciou após a gravação. O firmware de controle do jogo ainda não foi instalado.

## Identificação real do módulo

O barramento em SDA21/SCL22 respondeu no endereço 0x68. Cinco leituras consecutivas de WHO_AM_I devolveram 0x78 (120 decimal), não 0x70/0x71. O [driver oficial do kernel Linux](https://github.com/torvalds/linux/blob/master/drivers/iio/imu/inv_mpu6050/inv_mpu_iio.h) associa 0x78 ao MPU-6880; sua [tabela de dispositivos](https://github.com/torvalds/linux/blob/master/drivers/iio/imu/inv_mpu6050/inv_mpu_core.c) usa o mesmo mapa de acelerômetro/giroscópio do MPU-6500. Isso sustenta compatibilidade para o teste, sem autenticar o chip ou confirmar a marcação comercial do módulo.

O diagnóstico foi adaptado para aceitar também 0x78, recompilado e regravado com hash conferido. A identificação inicial foi preservada em `evidence/mpu-initial-identification.json`.

## Resultado do teste USB

**Comunicação com o sensor confirmada.** Foram recebidas 113 amostras reais em uma janela de 12 segundos, com valores finitos nos três eixos de aceleração e nos três de rotação. A norma da aceleração ficou entre 0,931 e 0,961 g (média 0,950 g), compatível com um sensor aproximadamente em repouso, considerando viés e falta de calibração. Nenhum erro de leitura foi relatado nessa janela. Isso não valida ainda a precisão, o comportamento sob movimento ou a detecção de saltos.

Relatório: `evidence/mpu-hardware-diagnostic.json`. A placa permanece com o diagnóstico instalado, sem Wi-Fi e sem emitir comandos ao jogo. A porta USB foi liberada ao final da leitura.

### Próxima etapa

Adaptar a identificação no firmware de jogo para o modelo compatível encontrado; configurar SDA21/SCL22 e o pareamento USB; instalar esse firmware; calibrar primeiro em repouso e testar movimentos controlados por um adulto. Validar o salto no jogo antes de testar com a criança. Wi-Fi continua como etapa posterior, sem necessidade de publicar o jogo.

## Controle do jogo instalado — continuação

O firmware `aventura_esp32` foi adaptado para aceitar WHO_AM_I 0x78 além dos IDs MPU-6500/9250/9255. SDA21, SCL22, I²C 100 kHz, amostragem nominal 100 Hz, USB 230400 baud, Wi-Fi desativado. Token de pareamento e configuração mantidos apenas nos arquivos locais privados. Compilação e gravação concluídas; todos os segmentos passaram na conferência de hash.

Teste físico ponta a ponta: MPU → ESP32 → USB → detector Python → UDP local → receptor real do Godot. Após calibração em repouso, o Godot ficou pronto e permaneceu pronto durante mais três segundos; 59 mensagens aceitas, zero descartadas, duração total de 6109 ms. O teste não carregou uma partida. Treze testes do receptor também passaram. Evidências: `evidence/esp32-usb-firmware.json` e `evidence/esp32-usb-game-calibration.json`. Detecção de salto corporal ainda não validada.

Novo atalho: `launchers/macos/Jogar com sensor USB.command`. Detecta a ESP32 CP2102 conectada, inicia o receptor e abre o jogo local diretamente na tela de calibração; encerra o receptor quando o jogo é fechado. Se a porta do jogo estiver ocupada, orienta fechar a outra conexão. Esse atalho usa o projeto local em `game`, e não altera o pacote publicado em `release`.
