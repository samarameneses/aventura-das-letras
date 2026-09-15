# Arquitetura atual

[Desenvolvimento](README.md) · [Sensor](../SENSOR.md) · [Planejamento original](../history/05-arquitetura.md)

O jogo executa localmente no Godot. Teclado, botões na tela e controle compatível permitem jogar sem hardware adicional. O ESP32 e o receptor Python acrescentam uma entrada de movimento opcional.

```text
Teclado / controle / botões ────────────────────────┐
                                                  ↓
ESP32 + IMU → USB ou Wi-Fi → receptor Python → jogo Godot
                                                  ↓
                             personagem, atividades e comemorações
                                                  ↓
                                      progresso salvo localmente
```

## Onde alterar cada parte

| Área | Local | Responsabilidade |
| --- | --- | --- |
| Entrada do projeto | `game/project.godot`, `game/scenes/main.tscn` | Configuração e cena inicial |
| Menus e fluxo | `game/scripts/main.gd`, `title_menu.gd` | Perfil, personagem e início das partidas |
| Fases e personagem | `game/scripts/world.gd`, `player.gd`, `adventure_terrain.gd` | Percurso, movimento e terreno |
| Poderes e acertos | `game/scripts/powers.gd`, `answer_effects.gd` | Habilidades e comemorações |
| Conteúdo educativo | `game/content/` | Atividades, currículo e palavras |
| Recursos utilizados pelo jogo | `game/art/` | Imagens e animações importadas pelo Godot |
| Arte original | `assets/`, `production/` | Originais, manifesto de procedência e prompts |
| Entrada de movimento | `game/scripts/sensor.gd`, `sensor_setup.gd` | Conexão e calibração no jogo |
| Receptor e detecção | `tools/esp32_receiver.py`, `imu_detector.py`, `sensor_bridge.py` | Transporte, reconhecimento e eventos locais |
| Microcontrolador | `firmware/aventura_esp32/` | Leitura do IMU e transmissão de amostras |

Os caminhos abreviados na mesma célula pertencem à pasta indicada no primeiro caminho.

## Integração física

O ESP32 envia aceleração e rotação por USB ou UDP na rede local. O receptor Python identifica movimentos e encaminha eventos ao jogo. O tráfego entre receptor e jogo usa `127.0.0.1:9250`; a entrada Wi-Fi do receptor usa UDP 9251. Preparação da placa, pareamento e limitações estão no [guia do sensor](../SENSOR.md).

O jogo e o detector não dependem de chamadas a modelos de IA durante a execução. Configurações de rede e de pareamento são geradas em cada instalação e ficam fora do Git.

## Organização e manutenção

Os scripts em `tools/` conservam os caminhos usados pela automação e pelo receptor. Consulte seu [índice por finalidade](../../tools/README.md) antes de criar outra ferramenta. Atalhos específicos do macOS ficam em `launchers/macos/`.

Os guias em `docs/` descrevem o uso atual; `docs/history/` registra decisões e entregas anteriores. Resultados gerados e material privado não são dependências do clone. Para validar uma mudança, siga [Testes e verificações](TESTING.md).
