# Integrar o sensor inercial ao jogo

Estado conferido em 8 de setembro de 2026, versão 0.12.0.

## Precisa publicar?

Não. O aplicativo instalado no Mac pode receber comandos do sensor por um programa local. A conexão entre esse programa e o jogo acontece dentro do próprio computador. Publicar na internet não é requisito para essa integração.

## O que já existe

- `game/scripts/sensor.gd`: recebe eventos locais de salto, controla a entrada no modo com sensor, calibração declarada pelo adaptador, mensagens recentes e duplicatas, e perda de conexão.
- `tools/sensor_bridge.py`: encaminha eventos de um adaptador ao jogo; também oferece simulação de bancada.
- Tela **Com sensor**, entrada após calibração, salto pela mesma ação dos botões e continuação sem sensor se a conexão cair.
- Evidência anterior em `evidence/sensor-integration.json`: um evento de salto recebido e desconexão detectada usando a ponte Python e comunicação local real. O campo `physical_sensor` é `false`.

## O que ainda falta

Não há firmware do MPU-9250 nem adaptador de USB/Bluetooth para a placa real. O programa existente não lê aceleração ou rotação e não reconhece um salto corporal. Também não verifica por si só se o aparelho está realmente parado: essa validação deve ser implementada no detector que envia a confirmação de calibração.

Precisamos identificar o sensor e, principalmente, a placa controladora usada no projeto de carros e como ela se comunicava com o Mac. O código antigo pode permitir reaproveitar a conexão.

## Caminho proposto

1. Identificar placa, módulo e código anterior; confirmar alimentação e pinos na documentação do módulo exato.
2. Implementar leitura de aceleração/rotação e registrar movimentos em bancada. Se a placa permitir, usar USB inicialmente para facilitar a análise dos sinais, com o dispositivo fora do corpo.
3. Implementar calibração em repouso e detecção temporal de salto, distinguindo movimentos comuns e evitando duplicatas.
4. Implementar o adaptador no Mac que entrega os eventos à ponte já existente e reinicia a calibração quando o jogo solicita nova conexão.
5. Para brincar com o dispositivo no corpo, preparar comunicação sem fio compatível com a placa e testar o conjunto primeiro com um adulto.
6. Abrir **Com sensor**, aguardar a calibração e entrar no jogo. Em Speed Run, a corrida já é automática: o sensor pode cuidar do salto e os botões continuam disponíveis para poderes.

Fluxo: sensor → placa controladora → conexão com o Mac → detector/adaptador → ponte local → salto no jogo.

Os intervalos atuais de calibração, proteção contra duplicatas e desconexão são valores iniciais de bancada, ainda não validados com esse hardware ou com as crianças. Publicar uma edição para navegador seria um trabalho separado; o receptor local atual pertence ao aplicativo instalado no Mac.

## Atualização posterior na mesma data

Após a confirmação de ESP32-S, foram escritos um firmware configurável para MPU-9250, um detector experimental e um receptor USB/Wi-Fi. A seção anterior registra o estado antes dessa implementação. Compilação e teste físico continuam pendentes. Consulte [ESP32 por USB e Wi-Fi](24-esp32-usb-wifi.md).
