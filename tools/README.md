# Ferramentas do projeto

[Desenvolvimento](../docs/development/README.md) · [Testes](../docs/development/TESTING.md) · [Sensor](../docs/SENSOR.md)

Execute os comandos a partir da raiz do repositório. Os scripts permanecem nesta pasta para preservar imports e os caminhos da automação.

| Finalidade | Arquivos principais |
| --- | --- |
| Abrir o jogo | `run_game.py`, `godot_runtime.py` |
| Preparar o ESP32 | `prepare_esp32.py` |
| Receber e interpretar movimentos | `esp32_receiver.py`, `imu_detector.py`, `sensor_bridge.py` |
| Ambiente de bancada do macOS | `play_sensor_usb.py`, `configure_sensor_wifi.py` |
| Diagnóstico físico | `read_imu_diagnostic.py`, `run_sensor_latency_lab.py` |
| Testes | `run_tests.py`, `test_*.py` |
| Revisão antes de publicar | `check_publication.py` |
| Conteúdo educativo | `build_curriculum.py` |
| Produção de arte | `register_generated.py`, `index_animation.py`, `finalize_animation_index.py` |
| Empacotamento e licenças | `verify_pack.gd`, `export_notices.gd` |
| Instalação local do motor | `install_godot_local.py` |

O [guia de testes](../docs/development/TESTING.md) identifica a suíte usada na CI. Laboratórios físicos e scripts de produção são executados separadamente; consulte o código e o guia relacionado antes de usá-los.

Ambientes Python, ferramentas instaladas, configurações e resultados locais são ignorados pelo Git. Os atalhos com dois cliques estão em [launchers/macos/](../launchers/macos/README.md).
