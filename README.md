# Aventura das Letras

**Pule. Descubra. Brinque.** Um jogo de plataforma 2D em português para explorar letras, sílabas e palavras — com teclado, controle ou um sensor de movimento opcional.

[![CI](https://github.com/Sa-Meneses/aventura-das-letras/actions/workflows/ci.yml/badge.svg)](https://github.com/Sa-Meneses/aventura-das-letras/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Godot 4.7.2](https://img.shields.io/badge/Godot-4.7.2-478cbf.svg)](https://godotengine.org/download/)

[Como jogar](COMO-JOGAR.md) · [Contribuir](CONTRIBUTING.md) · [Documentação](docs/README.md) · [English](README.en.md)

![Menu do jogo com quatro personagens em pixel art](docs/images/menu.png)

## O que você encontra

- **68 fases e 332 atividades:** alfabeto completo, famílias silábicas, palavras monossílabas e 100 palavras dissílabas.
- **Quatro personagens**, cenários de primavera e outono, rios, pontes, lava e mudanças de iluminação.
- **Aventura contínua e Speed Run**, oito superpoderes e progresso por perfil salvo no computador.
- **Aprendizagem acolhedora:** acertos ganham confetes e sons; erros preservam as descobertas e as vidas se renovam.
- **Narração em português**, quando uma voz compatível está disponível no sistema operacional.
- **ESP32 + sensor inercial opcionais:** USB ou Wi-Fi local para transformar movimentos em saltos. Todo o conteúdo também funciona sem hardware.

## Comece em poucos minutos

1. Instale o [Godot 4.7.2 Standard](https://godotengine.org/download/archive/4.7.2-stable/) para seu sistema. A edição .NET não é necessária.
2. Faça um fork ou clone:

   ```sh
   git clone https://github.com/Sa-Meneses/aventura-das-letras.git
   cd aventura-das-letras
   ```

3. No Godot, importe `game/project.godot`, aguarde a importação das imagens e pressione **F5 (Executar projeto)**.
4. Escolha o personagem e comece a aventura. O sensor é opcional.

Também é possível executar `python3 tools/run_game.py`, com Godot instalado no PATH, em `/Applications/Godot.app` ou indicado pela variável opcional `GODOT_BIN`. No macOS, `Jogar.command` abre esse mesmo código-fonte.

**Não precisa de conta, chave de API, arquivo .env ou serviço de nuvem para jogar.** O download inicial do motor e do código precisa de internet; o jogo roda localmente.

### Controles

| Ação | Teclado |
| --- | --- |
| Andar | Setas ou A/D |
| Pular | Espaço |
| Usar os poderes equipados | E / Q |
| Pausar | Esc |

Há botões na tela e suporte a controle compatível. Veja todas as opções em [Como jogar](COMO-JOGAR.md).

## Sensor opcional

O firmware para ESP32 e o receptor Python estão incluídos. Consulte [Instalar e conectar o sensor](docs/SENSOR.md) para gerar **suas próprias** configurações de rede e pareamento. O sensor é uma integração experimental; a montagem de referência foi experimentada fisicamente, mas outras placas, sistemas e movimentos precisam de validação.

## Para desenvolver

Requisitos: Godot 4.7.2 e Python 3.10 ou superior. O jogo usa GDScript e o receptor usa Python. As dependências USB são opcionais e ficam em `requirements-sensor.txt`.

```sh
python3 tools/check_publication.py
python3 tools/run_tests.py
```

Os testes geram seus arquivos em `evidence/`, ignorada pelo Git. O fluxo automático verifica a publicação, os protocolos Python, a importação do projeto e uma seleção de testes Godot. A plataforma de desenvolvimento validada originalmente é macOS Apple Silicon; contribuições para Windows e Linux são bem-vindas.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `game/` | Projeto Godot, cenas, scripts, conteúdo, arte e testes |
| `firmware/` | Código ESP32 e exemplo de configuração sem segredos |
| `tools/` | Receptores, detector de movimento, testes e ferramentas de produção |
| `assets/` | Arte original e manifesto de procedência |
| `production/` | Prompts e documentação de criação |
| `docs/` | Guias, arquitetura, decisões e capturas do jogo |

Fotografias pessoais, configurações de rede, backups de hardware, medições locais, executáveis instalados e exportações antigas ficam fora do repositório. Todos os recursos necessários para abrir o jogo no Godot estão incluídos.

## Colabore

Forks, correções, traduções, revisão pedagógica, acessibilidade, novas fases e testes de hardware são bem-vindos. Leia [CONTRIBUTING.md](CONTRIBUTING.md), veja o [roadmap](ROADMAP.md) e abra uma [issue](https://github.com/Sa-Meneses/aventura-das-letras/issues/new/choose) ou participe das [discussões](https://github.com/Sa-Meneses/aventura-das-letras/discussions).

## Criação e licença

Projeto desenvolvido com auxílio do Codex. As ilustrações foram produzidas com a ferramenta integrada de geração de imagens; a versão exata do modelo não foi exposta pela ferramenta. Prompts e procedência estão em [production/](production/README.md).

Código, documentação e recursos próprios publicados estão disponíveis sob a [licença MIT](LICENSE). Veja [créditos e componentes externos](THIRD_PARTY_NOTICES.md). O repositório não distribui fotografias pessoais de referência nem os binários do Godot ou do Arduino.
