# Atalhos para macOS

[Voltar ao projeto](../../README.md) · [Como jogar](../../docs/COMO-JOGAR.md) · [Instalar o sensor](../../docs/SENSOR.md)

Abra os arquivos `.command` com dois cliques no Finder. Mantenha esta pasta dentro do clone: os atalhos localizam `tools/` e `firmware/` a partir da raiz do projeto, independentemente da pasta aberta no terminal.

| Atalho | Função | Pré-requisitos |
| --- | --- | --- |
| [Jogar](<Jogar.command>) | Abre o código-fonte atual do jogo | Python 3 e Godot instalado |
| [Jogar com sensor USB](<Jogar com sensor USB.command>) | Abre o receptor e o jogo com sensor | Ambiente Python do sensor e ESP32 preparado |
| [Jogar com sensor Wi-Fi](<Jogar com sensor Wi-Fi.command>) | Abre o receptor e o jogo pela rede local | Ambiente do sensor e configuração Wi-Fi validada |
| [Conectar sensor Wi-Fi](<Conectar sensor Wi-Fi.command>) | Inicia somente o receptor | Python 3 e arquivo local de pareamento |
| [Configurar sensor Wi-Fi](<Configurar sensor Wi-Fi.command>) | Configura e grava a placa no ambiente de bancada | Arduino CLI, core ESP32, esptool e firmware de recuperação local |

Para começar sem hardware, use **Jogar.command** ou importe `game/project.godot` no Godot e pressione F5. O sensor não é necessário para acessar o conteúdo educativo.

Os atalhos do sensor pressupõem o ambiente de bancada descrito no [guia do sensor](../../docs/SENSOR.md). Para uma instalação nova, siga a preparação manual desse guia. Configurações privadas, ferramentas instaladas e firmware de recuperação não acompanham o repositório.
