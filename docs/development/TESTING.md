# Testes e verificações

[Desenvolvimento](README.md) · [Contribuir](../../CONTRIBUTING.md)

Execute os comandos a partir da raiz do repositório. Use Python 3.10+ e Godot 4.7.2 Standard. Se necessário, indique o executável do Godot na variável `GODOT_BIN`.

## Verificação de publicação

```sh
python3 tools/check_publication.py
```

Verifica arquivos versionados e candidatos não ignorados, procurando caminhos privados, padrões de credenciais e arquivos excessivamente grandes. A CI também executa Gitleaks no histórico. Essa verificação não substitui a revisão do conteúdo a publicar.

## Suíte automática

```sh
python3 tools/run_tests.py
```

O comando executa os testes Python do protocolo e receptor, importa os recursos no Godot e roda as suítes selecionadas: currículo, Speed Run, fluxo acolhedor, poderes, terreno, queda, saltos com sensor, reconexão, comemorações e aceitação.

As simulações rodam a 60 passos por segundo sem esperar o tempo real da partida. Os registros ficam em `evidence/`, ignorada pelo Git. Os testes usam perfis isolados e não reprogramam a placa.

`respawn_collectibles.gd` verifica que quedas restauram as opções coletadas ou ignoradas a partir do ponto de retorno, com nova coleta por salto, preservação do histórico e retomada do progresso salvo. Cobre letras, sílabas, palavras e quantidades nos modos manual e Speed Run.

`lava_jump.gd` verifica saltos nas bordas da lava, nos dois sentidos, com teclado e comandos simulados de sensor, nos modos manual e automático, com e sem velocidade extra. Também diferencia a passagem no ar de pisar ou aterrissar no interior da lava.

Para verificar apenas a camada Python:

```sh
python3 -m unittest discover -s tools -p 'test_sensor_bridge.py' -v
python3 -m unittest discover -s tools -p 'test_esp32_receiver.py' -v
```

## Verificação manual

- Mudanças no jogo: abra o projeto, teste a interação alterada e confira o modo sem sensor.
- Mudanças visuais: confira a tela em tamanhos diferentes e registre capturas sem dados pessoais.
- Mudanças nos atalhos: confira resolução dos caminhos, inclusive em pastas com espaços.
- Mudanças na documentação: confira links, comandos e instalação a partir de um clone novo.
- Mudanças no sensor: complemente os sinais sintéticos com testes físicos de falsos positivos, saltos perdidos e desconexão, descrevendo a montagem utilizada.

Testes sintéticos não demonstram precisão em todas as placas ou movimentos. Inclua no pull request os testes executados e qualquer limitação de ambiente.
