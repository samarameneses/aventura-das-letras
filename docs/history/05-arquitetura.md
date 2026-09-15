# Arquitetura 2D e modos de entrada

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


## Decisão proposta

Usar **Godot 4 estável, GDScript e sprites 2D em PNG**, com transparência quando necessária. Confirmar a versão instalada e a documentação antes de implementar. A arte em imagens deve ser criada com **ChatGPT Image 2.5**, a partir das referências dos quatro personagens e da direção visual escolhida.

A documentação do Godot apresenta movimento de plataforma com CharacterBody2D e animação por quadros com AnimatedSprite2D/SpriteFrames. Essas capacidades sustentam a proposta, sem garantir por si só acabamento ou desempenho. [Movimento 2D](https://github.com/godotengine/godot-docs/blob/master/tutorials/physics/using_character_body_2d.rst), [animação 2D](https://github.com/godotengine/godot-docs/blob/master/tutorials/2d/2d_sprite_animation.rst).

## Plataforma e ferramentas

Hipótese inicial: aplicativo de computador, com tela própria ou TV. Confirmar sistema operacional, controle disponível e tela. Exportação para celular, tablet ou navegador exigirá verificar entradas e integração do hardware separadamente.

| Ferramenta | Papel |
| --- | --- |
| Godot 4 | Física, animação 2D, fases, câmera, áudio, menus e progresso |
| ChatGPT Image 2.5 | Toda a arte em imagens do jogo |
| Preparação de arquivos | Exportar, organizar e empacotar imagens geradas em PNGs/atlas |
| Receptor local do sensor | Componente opcional, isolado da execução convencional |

A arte final deve seguir o modelo solicitado; não adicionar outro gerador de imagens por conveniência. Blender e Blockbench deixam de ser dependências do projeto. Godot usa licença MIT; conferir atribuições ao distribuir. [Licença](https://godotengine.org/license/).

## Estrutura do jogo

```text
Teclado / controle ─────────────────────────┐
                                          ↓
Sensor opcional → receptor opcional → Camada de comandos
                                          ↓
                        Personagem 2D + câmera lateral
                                          ↓
                        Escolha + coleta + feedback
                                          ↓
                        Atividades + progresso local
```

| Componente | Responsabilidade proposta |
| --- | --- |
| CharacterBody2D | Movimento horizontal, gravidade, salto e colisão |
| AnimatedSprite2D + SpriteFrames | Quadros de repouso, andar, correr, salto, queda, pouso e comemoração |
| Camera2D | Acompanhamento lateral e limites do cenário |
| TileMapLayer / TileSet | Terreno e plataformas com colisão definida |
| Area2D | Coleta, checkpoint, chegada e detecção de saída do percurso |
| Menus e interface | Perfil, quatro personagens, modo, pausa e texto pedagógico |
| Atividades | Conteúdo, instruções, alternativas e verificação da escolha |
| Assistência | Ajudar no movimento sem escolher a resposta |
| Progresso | Guardar tentativas, ajudas e sessão por perfil |

Usar camadas TileMapLayer na versão compatível escolhida; a documentação marca o TileMap antigo como depreciado em favor dessas camadas. [Godot — orientação de migração](https://github.com/godotengine/godot-docs/blob/master/classes/class_tilemap.rst).

## Personagens e arquivos

Manter quatro definições de personagem: `joao_miguel`, `luna`, `lucas_engenheiro` e `samara`, com os nomes exibidos **João Miguel**, **Luna**, **Lucas o Engenheiro** e **Samara**. Cada uma referencia retrato, SpriteFrames, offsets e aparência; compartilham a lógica de movimento e poderes.

Definir animações pela física: parado, movendo, subindo, descendo e pousando. Um salto não pode depender de terminar uma sequência de imagens para começar a mover. Áreas de colisão equivalentes tornam o percurso igualmente acessível aos quatro personagens.

Organização proposta: `assets/characters/<id>/`, `assets/terrain/`, `assets/backgrounds/`, `assets/items/`, `assets/effects/`, `assets/ui/`, `audio/` e `content/`. Imagens originais geradas e referências pessoais ficam separadas do pacote final. O manifesto de arte registra quadros, grade, duração, loop, pivot e modelo efetivamente usado.

A câmera nunca gira em torno do personagem. Dar visão antecipada das plataformas sem movimentos bruscos nas atividades. Reaparecer em um checkpoint válido, limpar velocidades/comandos e estabilizar a câmera. O retorno não pode duplicar a coleta nem apagar respostas já registradas.

## Contrato dos controles

Ações propostas: `move_left`, `move_right`, `jump`, `power`, `pause`, `repeat_instruction` e navegação/confirmação/voltar nos menus. Teclado e controle acionam a mesma camada de comandos; o sensor pode acrescentar um evento `jump` somente no modo corporal ativo.

| Estado | Comportamento |
| --- | --- |
| Sem sensor, padrão inicial | Não inicializar receptor nem exigir permissões, conexão ou calibração |
| Com sensor, conectando/calibrando | Manter opção de voltar ao modo convencional |
| Com sensor, pronto | Aceitar evento validado e manter botão de salto como apoio |
| Sensor perdido durante modo corporal | Pausar; oferecer reconectar ou Continuar sem sensor |
| Sensor perdido fora do modo corporal | Ignorar; não pausar nem exibir falha |
| Troca pelo menu de pausa | Preservar perfil, personagem, checkpoint e progresso; limpar entradas pendentes |

Ao sair do modo corporal, parar/ignorar o receptor e seus eventos; calibrar novamente ao entrar. Não combinar pressionamento de botão e evento de sensor em dois saltos no mesmo instante. A intenção é consumida uma vez pela física. Nenhum pacote atrasado pode disparar após troca de modo.

Sem sensor, todas as fases, personagens, poderes e recompensas continuam disponíveis. O jogo deve abrir e funcionar em uma máquina sem receptor instalado. O progresso não distingue recompensas por tipo de controle; o modo pode ser registrado apenas para interpretar dificuldades de movimento.

## Integração de hardware

Este componente só é necessário no modo Com sensor. A placa lê o sensor e transmite amostras ou eventos. No protótipo, guardar amostras ajuda a melhorar o detector. Depois de estabilizar, transmitir eventos pode simplificar a operação. Escolher conscientemente se a classificação roda na placa ou no receptor; evitar dois detectores emitindo o mesmo salto.

Uma arquitetura opcional é Bluetooth LE → receptor no computador → UDP apenas em `127.0.0.1` → Godot. A ponte poderá ser um pequeno aplicativo local; a linguagem será escolhida quando soubermos sistema e transporte. Godot documenta recepção UDP, mas isso não torna Bluetooth genérico nativo. [Godot — UDPServer](https://github.com/godotengine/godot-docs/blob/master/classes/class_udpserver.rst).

Se a placa atual já usa Wi-Fi, considerar envio pela rede local diretamente ao receptor ou ao jogo. Essa rota não fica restrita a `127.0.0.1`: exige configurar interface, identificar o dispositivo e lidar com a rede. Evitar confundir as duas arquiteturas.

### Contrato ilustrativo de evento

```json
{
  "protocol_version": 1,
  "device_id": "controle_01",
  "session_id": "sessao_atual",
  "sequence": 1042,
  "event_id": 27,
  "device_time_ms": 253901,
  "event": "jump"
}
```

Este formato é uma proposta, não uma API existente. O receptor registra seu próprio instante monotônico de recebimento. O relógio da placa não é diretamente comparável ao do computador. Para rejeitar atrasos de transporte com base no tempo de origem, precisamos estimar a relação entre os relógios; registrar só a chegada não prova que a mensagem é recente.

Regras: aceitar somente o dispositivo e sessão ativos; deduplicar `event_id`; verificar versão e sequência; limitar tamanho e frequência das mensagens; descartar filas na reconexão; impor validade curta aos comandos; liberar movimentos ao pausar ou perder conexão. Usar mensagens periódicas separadas para o estado de conexão.

Caso se use UDP para eventos, tratar perdas explicitamente. Repetição limitada com o mesmo identificador e deduplicação é uma opção a testar. Não presumir que UDP garante entrega ou ordem. Uma mensagem recuperada tarde demais deve ser descartada.

## Conteúdo separado do código

Uma atividade pode ser representada assim:

```json
{
  "id": "letra_a_nome_01",
  "locale": "pt-BR",
  "skill": "letter_name_recognition",
  "target": "A",
  "options": ["A", "M"],
  "instruction_audio": "encontre_a.ogg",
  "visual_model": false,
  "response_mode": "select_then_jump",
  "motor_assist": "generous"
}
```

O exemplo ilustra os campos; não implica que os áudios já existam. Conteúdo, alternativas e pré-requisitos serão revisados. Uma nova letra ou palavra não deve exigir copiar e alterar a lógica inteira do jogo.

Para palavras, acrescentar separação silábica, relações sonoras trabalhadas, imagem de significado, áudio e revisão pedagógica. Para números, acrescentar quantidade e representação visual.

## Progresso e operação local

Criar perfis locais separados, com personagem escolhido independentemente entre João Miguel, Luna, Lucas o Engenheiro e Samara. Guardar o modo de controle escolhido sem vincular o progresso ao hardware. Guardar atividade, resposta, ajuda utilizada, falha de movimento/sensor e sessão. Salvar de forma atômica e manter recuperação simples contra interrupção durante gravação.

O primeiro jogo não precisa de conta online, servidor, chat, anúncios ou IA respondendo ao vivo. Gerar toda a arte em imagens no ChatGPT Image 2.5 solicitado, revisar os textos e produzir/revisar áudio durante a produção; o jogo usa os materiais locais. Isso melhora previsibilidade e permite jogar offline após instalação. A conexão sem fio local do sensor pode continuar necessária.

Referências fotográficas dos personagens podem ficar fora da pasta distribuída do jogo. Exportar sprites, cenários e demais imagens finais, não as fotos de origem. Registros brutos do sensor servem ao desenvolvimento, com controle local do responsável e possibilidade de apagar.

## Metas e aceitação

- Concluir o percurso com cada um dos quatro personagens usando apenas teclado; repetir com controle compatível.
- Abrir, selecionar personagem, jogar, pausar e salvar sem sensor/receptor instalado.
- Trocar de modo sem reiniciar a fase ou perder progresso.
- Perder conexão somente no modo corporal gera pausa recuperável; continuar sem sensor funciona imediatamente.
- Buscar 60 quadros por segundo no aparelho final; verificar nitidez na escala real de exibição.
- Medir resposta do salto por botão e, separadamente, do gesto físico até a tela.
- Validar animações, colisões, checkpoint, coleta única e legibilidade dos textos.
- Manter letras e números como texto de fonte revisada sobre os suportes ilustrados.

Essas são metas de projeto; ainda não existem implementação ou medições.

## Direção de renderização em pixel art

O elenco e o ambiente usam pixel art obrigatória. Projetar tela lógica inicial de 320×180, células de personagem de 64×64 e terreno de 16×16 como metas a validar. A escala de exibição deve preservar pixels quadrados e evitar filtragem suave. Verificar tremor de pixels com câmera e personagens em movimento antes de fixar a configuração da engine. A interface pedagógica pode ter texto em resolução maior para garantir legibilidade.

Os PNGs ampliados do gerador ainda não são prova de grade nativa correta. Preparar transparência, paleta, alinhamento e dimensões antes de montar SpriteFrames/TileSet. As versões anteriores de ilustração lisa foram marcadas como históricas no manifesto. Samara usa a roupa Nude Project indicada pela família.
