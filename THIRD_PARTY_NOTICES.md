# Créditos e componentes externos

## Conteúdo do projeto

Código, conteúdo pedagógico, documentação, efeitos sonoros próprios e recursos gráficos publicados são disponibilizados sob a licença MIT da raiz. As imagens do jogo foram produzidas com a ferramenta integrada `image_gen`; a versão exata do modelo não foi exposta. Consulte `assets/manifest.json` e `production/prompts/` para procedência. Fotografias pessoais de referência não são distribuídas.

## Dependências instaladas separadamente

- [Godot Engine](https://godotengine.org/license/): licença MIT, com componentes externos sob suas próprias licenças. Ao distribuir o motor junto de uma exportação, inclua também os avisos completos do Godot. `tools/export_notices.gd` ajuda a gerar esses avisos.
- [pySerial](https://github.com/pyserial/pyserial): licença BSD de três cláusulas; necessário somente para a conexão serial USB.
- [Arduino core for ESP32](https://github.com/espressif/arduino-esp32): consulte a licença LGPL-2.1 e os avisos dos componentes do pacote usado para compilar o firmware.
- [esptool](https://github.com/espressif/esptool): licença GPL-2.0; ferramenta opcional de programação da placa, instalada separadamente.

O repositório não inclui os executáveis nem as instalações dessas ferramentas. As fontes técnicas e visuais citadas nos documentos não transferem direitos sobre materiais externos, marcas ou fotografias.
