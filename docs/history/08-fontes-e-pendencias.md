# Fontes, decisões e pendências — revisão de pixel art

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


A revisão 2 incorpora a correção explícita da família: plataforma 2D inspirada no estilo dos jogos clássicos de plataforma, quatro personagens, imagens no ChatGPT Image 2.5 e opção completa de jogar sem sensor. A proposta anterior de mundo 3D foi substituída.

## Decisões confirmadas

- Jogo próprio de plataforma 2D com visão lateral, rolagem horizontal e **pixel art obrigatória**, inspirado nos jogos clássicos de plataforma em pixel art.
- Samara usa o look Nude Project fornecido: moletom marrom, jeans claro largo e sapatos baixos escuros. A imagem da roupa não substitui sua referência pessoal de rosto/cabelo.
- Personagens selecionáveis: **João Miguel**, **Luna**, **Lucas o Engenheiro** e **Samara**.
- A família forneceu as quatro referências, copiadas e identificadas conforme sua mensagem; a primeira arte de cada personagem já foi criada.
- Toda a arte em imagens será criada com **ChatGPT Image 2.5**, conforme solicitado.
- Modo **Sem sensor** completo, com as mesmas fases, personagens, poderes e recompensas.
- Modo **Com sensor** opcional para o salto físico; movimento e aprendizagem permanecem acessíveis por botão.
- Manter letras, números, sílabas, palavras, poderes de velocidade e retorno após queda virtual.

## Referências técnicas

As fontes de sensor e alfabetização vêm da pesquisa inicial de 6 de setembro de 2026. A documentação de plataforma e sprites 2D foi consultada nesta revisão via Context7, começando pela resolução do identificador Godot. Conferir a versão efetiva antes de implementar.

| Referência | O que sustenta | Limite |
| --- | --- | --- |
| [Godot — CharacterBody2D](https://github.com/godotengine/godot-docs/blob/master/tutorials/physics/using_character_body_2d.rst) | Movimento, gravidade e salto de plataforma 2D | Exemplo não é física final validada |
| [Godot — animação de sprites](https://github.com/godotengine/godot-docs/blob/master/tutorials/2d/2d_sprite_animation.rst) | AnimatedSprite2D, SpriteFrames e folhas de quadros | Arte gerada ainda precisa de revisão |
| [Godot — TileMap e TileMapLayer](https://github.com/godotengine/godot-docs/blob/master/classes/class_tilemap.rst) | Orientação de usar camadas em vez do TileMap antigo | Conferir versão instalada |
| [Godot — UDPServer](https://github.com/godotengine/godot-docs/blob/master/classes/class_udpserver.rst) | Comunicação local opcional com receptor | Não é suporte automático a Bluetooth |
| [Godot — licença](https://godotengine.org/license/) | Licença da engine | Materiais adicionais têm condições próprias |
| [TDK — MPU-9250](https://invensense.tdk.com/wp-content/uploads/2015/02/PS-MPU-9250A-01-v1.1.pdf) | Componentes e interfaces do sensor | Não valida detecção de salto infantil |
| [Analog Devices — navegação inercial](https://www.analog.com/en/resources/analog-dialogue/articles/strapdown-inertial-navigation-system-based-on-an-imu-and-a-geomagnetic-sensor.html) | Limites da estimativa de posição por IMU | Experimento com outro sensor, não benchmark do kit da família |
| [Espressif — Bluetooth](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/bt-architecture/overview.html) | Capacidades da família ESP32 | Modelo da placa ainda desconhecido |
| [EEF — alfabetização inicial](https://educationendowmentfoundation.org.uk/early-years/evidence-store/early-literacy) | Princípios de sons, linguagem e escrita | Não valida este jogo em português brasileiro |
| [EEF — consciência fonológica](https://educationendowmentfoundation.org.uk/reading-house/phonological-awareness) | Palavras, sílabas e fonemas | Adaptar às crianças e ao contexto |
| [OpenAI — Images in ChatGPT](https://help.openai.com/en/articles/11084440-chatgpt-image-library) | Criação e edição de imagens | Na pesquisa inicial mencionava Images 2.0; não confirma a seleção 2.5 na conta |

## Requisito do modelo de imagem

A família informa que tem acesso ao ChatGPT Image 2.5 e exige seu uso. Isso é requisito de produção, não verificação técnica já realizada. Antes da geração, confirmar o modelo exposto na ferramenta/conta; não atribuir outra versão a 2.5 e não substituir silenciosamente. A documentação e o protótipo com formas temporárias podem avançar sem depender dessa verificação.

Todas as imagens artísticas serão produzidas no modelo solicitado. Texto pedagógico e nomes permanecem texto real de fonte revisada; imagens de suportes, retratos e decoração seguem a geração pedida. Áudio é uma etapa separada de produção.

## Hipóteses ainda abertas

| Hipótese | Motivo | Quando confirmar |
| --- | --- | --- |
| Computador, possivelmente com TV | Facilita versão inicial e hardware opcional | Antes de configurar exportação e controles |
| Um jogador por vez | Seleção de personagem não implica multiplayer | Antes de planejar cooperação |
| Resolução lógica e paleta exatas da pixel art | Estilo pixelado já confirmado; valores são metas de produção | Na normalização e teste dentro da engine |
| Sensor é MPU-9250 | Nome próximo a “MCU 9250” | Antes da integração corporal |
| Português brasileiro | Idioma e contexto da família | Antes de gravar áudio |
| Física equivalente nos quatro | Facilita acesso a todas as atividades | Validar no percurso com as silhuetas finais |

## Informações pendentes

1. Revisão familiar da semelhança das quatro artes e dos detalhes de roupa completados fora do enquadramento das fotos.
2. Idades e repertório das crianças que jogarão; não confundir com idade dos personagens.
3. Controle físico e eventual tela/TV ou outro aparelho; o Mac Apple M4 atual já foi usado como destino inicial.
4. Acesso efetivo ao modelo de imagem solicitado no momento da produção.
5. Identificação do sensor, módulo, placa e código anterior, apenas para o modo corporal.
6. Tempo/orçamento de produção e eventual intenção de distribuir além da família.

O formato 2D e o modo sem sensor não são pendências. Não reabrir a escolha de mundo de blocos ou adaptação de outro jogo sem uma nova orientação da família.

## O que ainda precisa ser demonstrado

Há uma primeira fase jogável neste Mac Apple M4. O conjunto selecionado tem 35 imagens pixeladas, 30 integradas, incluindo 20 folhas de animação. Os testes de percurso dos quatro personagens e a ponte local do sensor passaram. A precisão do gesto físico, a autonomia do sensor, o desempenho em outros aparelhos e os resultados de aprendizagem ainda dependem de validação específica. Consulte as evidências da versão 0.1.0 no documento de entrega.

Registro do lote: [produção de arte](../../production/README.md). A geração integrada utilizada não informou o identificador do modelo; não foi registrada como confirmação de Image 2.5.
