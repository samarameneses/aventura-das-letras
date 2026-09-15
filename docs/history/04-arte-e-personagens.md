# Arte 2D e quatro personagens personalizados

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


## Direção e ferramenta de geração

Criar uma aventura de plataforma 2D com visão lateral e **pixel art obrigatória**, conforme correção da família. A referência são os jogos clássicos de plataforma em pixel art. Usar pixels quadrados visíveis, silhuetas compactas, contornos em degraus, paleta reduzida e poucas sombras sólidas. A ilustração lisa do lote anterior foi substituída. Adotar como proposta inicial o acabamento de plataformas clássicos de 16 bits.

**Toda a arte em imagens deve ser gerada com ChatGPT Image 2.5, por solicitação explícita da família.** Isso inclui estudos, personagens, quadros de animação, retratos, cenários, peças de chão/plataforma, objetos, ilustrações educacionais, efeitos e gráficos da interface. Usar os nomes e aparência dos quatro personagens da família na identidade do jogo.

Verificar acesso efetivo à versão solicitada antes de gerar. O relato de acesso está registrado, mas as ferramentas desta conversa não comprovaram seleção desse modelo. Não chamar outro modelo de 2.5 nem escolher outro gerador silenciosamente. Isso não impede concluir a documentação ou preparar o jogo sem arte final.

As imagens passam por revisão, exportação, recorte e organização de quadros. Alterações visuais devem usar a ferramenta de imagem indicada. Empacotamento dos arquivos não substitui o gerador nem significa que a IA forneceu animações perfeitas de primeira.

## Referências dos personagens

| Personagem | Referências | Roupa e acessórios | Traços essenciais | Estado |
| --- | --- | --- | --- | --- |
| João Miguel | Recebida — registro local não distribuído (`references/characters/previews/joao_miguel.png`) | Blusa verde; calça e tênis completados como proposta | Cabelo escuro curto e sorriso | Arte pixelada criada; normalização e transparência pendentes |
| Luna | Recebida — registro local não distribuído (`references/characters/previews/luna.png`) | Blusa listrada rosa/vinho, calça rosa, tênis claros | Cabelo loiro comprido, presilha e sorriso | Arte pixelada criada; normalização e transparência pendentes |
| Lucas o Engenheiro | Recebida — registro local não distribuído (`references/characters/previews/lucas_engenheiro.png`) | Camiseta marrom, calça clara e tênis escuros | Óculos arredondados, cabelo escuro e barba | Arte pixelada criada; normalização e transparência pendentes |
| Samara | Recebida — registro local não distribuído (`references/characters/previews/samara.png`) | Look Nude Project — registro local não distribuído (`references/outfits/samara-nude-project.webp`): moletom marrom, jeans claro largo e sapatos baixos escuros | Cabelo escuro ondulado e franja; mangas cobrem a tatuagem | Arte pixelada criada; normalização e transparência pendentes |

Preservar cabelo, tom de pele, aparência da idade, proporções, roupas e sinais visuais observados nas referências. Não inventar características e tratá-las como reais. Não presumir que todos são crianças. Capacete, ferramentas e uniforme de Lucas o Engenheiro só entram se estiverem nas referências ou forem pedidos.

Gerar uma imagem principal de cada personagem e derivar as demais dela. Conferir semelhança com a família antes de multiplicar animações. A estilização simplifica detalhes; a meta é reconhecimento consistente, não garantia de reprodução fotográfica exata.

## Materiais e ferramentas

| Material | Uso | Entrega proposta |
| --- | --- | --- |
| Folha de referência | Fixar aparência e proporções | Imagem principal e vistas coerentes |
| Sprites de personagem | Movimento dentro da fase | PNGs com transparência real |
| Sprite sheet | Organizar uma animação | Grade regular e metadados |
| Retratos | Seleção dos quatro personagens | PNG no mesmo enquadramento relativo |
| Tiles de terreno | Chão e plataformas repetíveis | Peças alinhadas em atlas |
| Fundos | Céu, montanhas, vegetação | Camadas separadas para rolagem |
| Objetos e efeitos | Poderes, checkpoint, coleta e chegada | Imagens e sequências |
| Interface | Painéis, molduras, ícones e botões | Arte sem textos variáveis incorporados |

Blender, Blockbench, malhas, rigs e exportação GLB/glTF não são necessários. A animação recomendada usa imagens sucessivas, integradas como quadros de sprite. [Godot — animação de sprites 2D](https://github.com/godotengine/godot-docs/blob/master/tutorials/2d/2d_sprite_animation.rst).

## Contrato visual e de animação

Os modos **Sem sensor** e **Com sensor** usam os mesmos sprites, retratos, animações, cenários e poderes para os quatro personagens. Nenhuma imagem ou aparência fica exclusiva do dispositivo corporal; o botão e o gesto acionam a mesma animação de salto.

Valores propostos, ajustáveis após testar a primeira animação:

- Visão lateral voltada para a direita como base, com rosto reconhecível sem transformar a câmera em isométrica.
- Meta de tela lógica 320×180, ampliada em fatores inteiros quando possível; terreno em unidades lógicas de 16×16 pixels. Preservar pixels nítidos sem interpolação suave. Letras podem usar uma camada de interface com resolução maior para leitura.
- Meta inicial de célula de personagem 64×64 pixels lógicos, com silhueta aproximada de 32×48 e margens. Esta é uma meta de preparação: as saídas geradas são imagens maiores e ainda não comprovam uma grade nativa exata. Normalizar e verificar antes de declarar sprite pronto.
- Cada personagem conserva escala, roupa, rosto e apoio dos pés entre quadros. Pivot alinhado pela base, com offsets explícitos quando necessário.
- Colisão definida no jogo, independentemente do contorno de cada PNG. Área de colisão equivalente nos quatro para manter a mesma dificuldade.
- Paleta alvo de cerca de 16–24 cores por personagem, sem gradientes, linhas suavizadas ou detalhes menores que a grade. Essa contagem precisa ser verificada na preparação dos arquivos.
- Fundos menos contrastados que plataformas e alvos. Decoração não deve parecer chão sólido quando não tem colisão.
- Iluminação coerente; evitar sombra desenhada que prenda visualmente os pés ao chão durante o salto.

| Animação | Quadros sugeridos | Reprodução |
| --- | --- | --- |
| Repouso (`idle`) | 4 | Loop suave |
| Andar (`walk`) | 8 | Loop com apoio consistente |
| Correr (`run`) | 8 | Loop para velocidade |
| Subida do salto (`jump`) | 2 | Conforme a física |
| Queda (`fall`) | 2 | Enquanto desce |
| Pouso (`land`) | 2 | Transição breve |
| Comemorar (`celebrate`) | 4 | Após atividade |

São 30 quadros por personagem, 120 no elenco, antes de variações. É estimativa de produção, não quantidade garantida de gerações: haverá revisão e quadros rejeitados. Gerar uma ação por vez e testar no jogo antes de produzir as demais.

Para a esquerda, espelhar apenas quando não houver assimetrias relevantes. Se roupas ou acessórios exigirem fidelidade lateral, gerar a direção oposta usando a mesma referência. Nenhum nome ou palavra deve estar dentro de um sprite que será espelhado.

## Escrita pedagógica

Letras, números, nomes e palavras serão texto real com fonte legível, incluindo acentos e Ç. A arte dos suportes, cartões e ilustrações vem do Image 2.5. Isso evita letras erradas, nomes espelhados e gerar novamente uma imagem a cada mudança de conteúdo.

Os prompts reservam espaços para esses textos. Revisar os símbolos em tamanho real de jogo.

## Processo de produção

1. Receber as referências dos quatro e preencher fichas.
2. Confirmar a ferramenta/modelo solicitado e gerar uma direção de arte da fase.
3. Criar imagem principal e retrato de cada personagem.
4. Gerar repouso e caminhada de um personagem para validar o estilo em movimento.
5. Conferir transparência, escala, alinhamento e continuidade; corrigir inconsistências.
6. Completar as animações dos quatro a partir de suas referências principais.
7. Gerar terreno, fundos em camadas, objetos, efeitos e interface na mesma linguagem.
8. Organizar PNGs e atlas com grade, quantidade de quadros, duração e loop.
9. Importar no Godot, ajustar pivôs/colisões e testar com teclado e controle.
10. Verificar a mesma leitura no modo com sensor.

Fundo quadriculado desenhado não é transparência real. Uma folha gerada pode ter células desalinhadas ou mudar a roupa entre quadros; inspecionar antes de integrar. O salto visível acompanha a física, sem animação longa que bloqueie comandos.

## Registro e entrega

Para cada arquivo final, registrar personagem/categoria, referência, prompt, versão efetivamente identificada do modelo, tamanho, quadros, revisão e caminho no projeto. Guardar original gerado e arquivo preparado.

Verificar semelhança, proporções, cores, ausência de membros extras, partes cortadas, transparência, continuidade, terreno sem emendas e leitura na tela. Fotografias de referência não entram no pacote jogável distribuído.

## Lote atual em pixel art

As seis bases iniciais de pixel art estão no [registro de produção](../../production/README.md) e na [galeria](../../production/GALERIA.html): quatro personagens, fundo e terreno. Samara foi gerada combinando sua foto pessoal como identidade e a nova referência como roupa; não foi usada a identidade da modelo do catálogo.

Essas seis bases são pixel art ampliada em RGB sem alpha; grade lógica uniforme, paleta exata, transparência e integração na engine precisam de preparação/validação. As animações anteriores em ilustração lisa estão superadas e não devem ser misturadas com este lote.

## Ampliação: retratos e objetos

O [Lote 03](../../production/LOTE-03.md) acrescenta oito imagens: quatro retratos, suporte vazio de letra, tênis de velocidade, checkpoint ativado e portal de chegada. Estes oito PNGs são RGBA com transparência real verificada. Normalização de grade, paleta, escala e bordas permanece pendente; ainda não são assets integrados ou animações. Total atual: 14 bases ativas.
