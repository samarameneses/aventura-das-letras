# Entrega 0.1.0 — primeira fase

Data: 7 de setembro de 2026. Destino verificado: Mac Apple M4, Godot 4.7.2 oficial, renderizador Compatibility/OpenGL sobre Metal.

## O que foi entregue

- Fase lateral completa com três escolhas de letras e uma de quantidade; início, plataformas, vão, ponto de retorno e chegada.
- Quatro personagens selecionáveis; cinco folhas de animação por personagem (120 quadros no total), mapeadas para parado, caminhada, corrida, subida, queda, pouso e comemoração.
- Perfis independentes da aparência; salvamento local com gravação temporária e recuperação de backup.
- Modo sem sensor padrão; teclado, mapeamento de controle, menus com foco, remapeamento, pausa, pista e repetição da instrução.
- Narração do sistema em português do Brasil com volume ajustável. A disponibilidade da voz foi verificada; não foi feita avaliação auditiva humana nem teste com criança.
- Poder temporário de velocidade, sem acelerar a decisão nas atividades.
- Receptor opcional e ponte Python para teste da comunicação; timeout, desafio de conexão, sequência, deduplicação e descarte de mensagens atrasadas.
- Pacote `release/Aventura.pck`, abertura local por `Aventura das Letras.app` / `Jogar.command`, licenças do motor em `release/LICENCAS.txt`.

O executável oficial arm64 foi extraído do aplicativo universal do Godot, após conferência do SHA512 oficial. O aplicativo original e seus metadados foram preservados; nenhuma proteção do macOS foi desativada. O launcher local não é uma distribuição notarizada. As fotografias pessoais e referências de roupa não fazem parte do pacote de jogo.

## Evidências

| Verificação | Resultado / arquivo |
| --- | --- |
| Percurso físico dos quatro personagens, quatro coletas e chegada; salvamento, poder, pausa e protocolo | 100 verificações aprovadas, zero falhas: `evidence/acceptance.json` e `.log` |
| Ponte Python real → UDP local → receptor Godot; salto único e desconexão | Aprovado: `evidence/sensor-integration.json` |
| Dados atrasados e identidade de sessão da ponte | 3 testes aprovados: `tools/test_sensor_bridge.py` |
| Navegação nos menus por teclado e eventos de controle | Aprovado: `evidence/ui.json`; eventos simulados, não controle físico |
| Carregamento das animações dos quatro personagens a partir do pacote e gravação | Aprovado: `evidence/pack-verification.json` |
| Renderização no Mac | `evidence/menu.png`, `character-0.png` a `character-3.png`, `pause.png`, `settings.png`, `finish.png` |

As verificações de percurso usam física real do jogo e comandos de entrada, percorrendo os desafios. Testes específicos de queda e checkpoint posicionam o personagem de propósito para provocar essas situações. Isso não representa observação de uma criança jogando nem medição de aprendizagem. Não há benchmark formal de FPS, teste em outro computador ou teste de duração de bateria do sensor.

## Arquitetura implementada

`game/scripts/main.gd` monta menus, HUD e narração; `world.gd` monta o percurso com corpos estáticos e coordena escolhas; `player.gd` controla movimento e animações; `data.gd` concentra perfis, atividades e entradas; `sensor.gd` recebe o protocolo opcional. O mundo tem resolução lógica de 320×180; a janela padrão de 960×540 amplia por três com filtro nearest. As regiões dos sprites e seus pivôs de pés ficam em `game/art/animations.json`. Os PNGs gerados são preservados, sem recorte destrutivo.

Esta implementação usa corpos estáticos para o terreno e um fundo panorâmico; o TileMap e a paralaxe propostos no planejamento não foram necessários nesta fase. A arte tem aparência pixelada; a paleta e uma grade nativa uniforme de produção ainda não passaram por acabamento manual de pixel artist.

## Ponte do sensor

O receptor só abre ao escolher Com sensor e escuta `127.0.0.1:9250`. O modo sem sensor não abre socket. A ponte é `tools/sensor_bridge.py`, usa apenas a biblioteca padrão do Python e não instala firmware.

Teste de bancada: abrir Com sensor no jogo e executar `python3 tools/sensor_bridge.py --simulate`. Após cerca de três segundos, escolher Entrar no jardim. No terminal da ponte, J seguido de Enter emite um salto simulado. Ctrl+C encerra; o jogo deve oferecer continuação pelos botões.

Para o hardware, um adaptador ainda precisa ler a placa real e alimentar `--stdin` com uma linha JSON por evento. Ele deve validar repouso e detectar o gesto. A ponte NÃO estima salto a partir de aceleração e não substitui esse adaptador. Eventos admitidos: `calibration_start`, `ready` com `stable: true`, `jump` e `heartbeat`, todos com `sent_at_ms` medido no Mac no momento da aquisição. Eventos com idade acima de 150 ms não são encaminhados. A entrada deve ser contínua, incluindo heartbeat; silêncio deixa o receptor detectar a desconexão. A mensagem de nova conexão exige reiniciar a calibração do adaptador.

Protocolo UDP versão 1: `hello` recebe `challenge`; os demais pacotes contêm desafio, `session_id`, `device_id`, `sequence`, `sent_at_ms`, `event` e, no salto, `event_id`. O receptor exige três segundos de calibração estável declarada pelo adaptador, aceita pacotes de até 200 ms, limita saltos a intervalo mínimo de 400 ms e pausa após 650 ms sem sinal. Esses valores são parâmetros iniciais de bancada, não parâmetros validados em crianças.

## Próximos incrementos

1. Teste familiar curto do jogo sem sensor e ajustes de instruções/alcance.
2. Receber placa e código do projeto de carros, implementar leitura e detecção temporal do gesto, medir falsos saltos e perdas em bancada com adulto.
3. Expandir letras e quantidades e só então sílabas e palavras, com revisão pedagógica e tarefas adequadas ao repertório das crianças.
4. Refinar pixel art, trilha/efeitos, novos mundos e distribuição independente quando o primeiro percurso estiver validado pela família.

Referências de implementação: [TTS do Godot](https://docs.godotengine.org/en/stable/tutorials/audio/text_to_speech.html), [exportação](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html), [linha de comando](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html). Documentação consultada por Context7. Modelo da ferramenta de imagem: não exposto; Image 2.5 não foi tecnicamente confirmado.
