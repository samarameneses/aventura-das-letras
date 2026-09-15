# ESP32 e sensor de movimento

O sensor é opcional. O Godot executa o jogo; o ESP32 envia medidas de aceleração e rotação; um receptor Python reconhece os gestos e encaminha saltos ao jogo. O modo sem sensor oferece o mesmo conteúdo.

## Montagem de referência e estado

A montagem experimentada no desenvolvimento usa ESP32 clássico (NodeMCU ESP-32S/ESP32-D0WD-V3), MPU identificado pelo firmware, SDA no GPIO 21 e SCL no GPIO 22. O sensor foi experimentado fisicamente com o jogo. Isso não estabelece compatibilidade universal ou precisão em todos os movimentos: confira a placa, a alimentação, a identificação do sensor e a pinagem antes de conectar. Leia as notas técnicas em [24 — ESP32](24-esp32-usb-wifi.md) e [25 — MPU](25-teste-fisico-do-mpu.md).

## Preparação a partir de um clone

Instale Godot conforme o README e Python 3.10+. Para USB:

```sh
python3 -m venv tools/.sensor-venv
# macOS / Linux:
tools/.sensor-venv/bin/python -m pip install -r requirements-sensor.txt
# Windows: use tools/.sensor-venv/Scripts/python.exe no lugar do caminho acima.
```

Gere as configurações usando os GPIOs confirmados da sua montagem. O exemplo a seguir é específico da montagem de referência:

```sh
python3 tools/prepare_esp32.py --sda 21 --scl 22
```

Esse comando cria `firmware/aventura_esp32/config.h` e `firmware/local/pairing-token.txt`. Não grava a placa. Os arquivos são privados, ignorados pelo Git e devem ser diferentes em cada instalação.

Abra `firmware/aventura_esp32/aventura_esp32.ino` no Arduino IDE, instale o pacote Espressif ESP32 **2.0.17** usado na montagem de referência, selecione sua placa e porta, compile e grave. Essa ação substitui o programa instalado na placa. Feche o monitor serial antes de iniciar o receptor.

## Jogar por USB

Com a porta serial real no lugar do marcador:

```sh
tools/.sensor-venv/bin/python tools/esp32_receiver.py --usb PORTA_SERIAL --token-file firmware/local/pairing-token.txt
```

Em outro terminal, execute `python3 tools/run_game.py`, selecione **Com sensor**, deixe o sensor parado durante a calibração e comece. No Windows, uma porta típica tem formato `COM3`; no macOS/Linux, use o dispositivo informado pelo sistema.

## Jogar por Wi-Fi local

Gere a configuração com o endereço IPv4 do computador. Substitua `IP_DO_COMPUTADOR` pelo endereço real:

```sh
python3 tools/prepare_esp32.py --sda 21 --scl 22 --wifi --mac-ip IP_DO_COMPUTADOR
```

A ferramenta solicita SSID e senha no terminal; a senha não é exibida. Recompile e grave o sketch no Arduino IDE. Depois inicie:

```sh
python3 tools/esp32_receiver.py --wifi --bind IP_DO_COMPUTADOR --token-file firmware/local/pairing-token.txt
```

O computador e a placa devem se comunicar na mesma rede local. O receptor escuta na porta UDP 9251 e conversa com o jogo em `127.0.0.1:9250`. O pareamento não criptografa o tráfego. Se o endereço do computador mudar, atualize a configuração e regrave a placa.

## Atalhos avançados de macOS

`Configurar sensor Wi-Fi.command` e `tools/configure_sensor_wifi.py` automatizam um ambiente de bancada específico: exigem Arduino CLI local, core ESP32, esptool e um firmware USB de recuperação previamente validado. Esses arquivos privados não acompanham o clone. Para uma instalação nova, use o procedimento manual acima. `Jogar com sensor USB.command` e `Jogar com sensor Wi-Fi.command` também pressupõem esse ambiente preparado. O início mais portátil é abrir o receptor e o Godot separadamente.

## Testes

`python3 tools/run_tests.py` cobre o detector com sinais sintéticos e comportamentos do jogo, sem reprogramar nem conectar uma placa. Testes físicos devem observar falsos positivos, saltos perdidos, desconexão e retorno ao controle manual. Nunca publique tokens, SSIDs pessoais, dumps de firmware ou dados de participantes nos resultados.
