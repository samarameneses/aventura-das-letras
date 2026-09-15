# Prompts para a plataforma 2D

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


Para iniciar uma nova aventura com seu próprio elenco, use o **[prompt mestre personalizável](PROMPT-MESTRE.md)**. Os exemplos abaixo documentam a direção de arte deste jogo e podem ser adaptados.

As versões públicas dos prompts de produção estão no [registro de produção](../production/README.md). O projeto jogável fica em `game/`. Na produção original, a família solicitou ChatGPT Image 2.5, mas a ferramenta não expôs a versão efetivamente utilizada. Em um novo projeto, confirme a disponibilidade do modelo antes de gerar imagens e registre apenas informações verificadas. Preencha os campos entre colchetes com as características do seu elenco.

## 1. Direção visual da fase

```text
Crie uma imagem de direção de arte para “Aventura das Letras”, jogo 2D de
plataforma com visão lateral e rolagem horizontal, inspirado no estilo de
jogos clássicos de plataforma. Use PIXEL ART de baixa resolução, pixels
quadrados grandes, paleta reduzida, contornos em degraus e acabamento de 16 bits.
Sem gradientes, antialiasing ou linhas de ilustração lisa.

Mostre o Jardim das Letras: chão de grama, plataformas baixas, árvores,
um pequeno vão, checkpoint e chegada. O percurso deve ser legível e os
locais de pouso visíveis. Fundo menos contrastado que a área jogável.
Reserve suportes vazios para letras que serão inseridas como texto no jogo.

Composição 16:9, vista estritamente lateral, sem perspectiva isométrica.
Use identidade visual própria da aventura e da família. Não inclua texto
pedagógico dentro da imagem. Esta é uma referência de composição; terreno,
fundos e objetos jogáveis serão produzidos em arquivos separados depois.
```

## 2. João Miguel — aparência principal

```text
Use as imagens de referência anexadas para criar João Miguel como personagem
jogável de um jogo de plataforma 2D. Preserve cabelo, tom de pele, aparência
da idade, proporções e traços visíveis que tornam a pessoa reconhecível.
Traços prioritários da família: [PREENCHER]. Roupa escolhida: [PREENCHER].
Não invente acessórios nem altere características pessoais por preferência.

Siga a direção pixel art de baixa resolução anexada. Entregue uma imagem de corpo inteiro,
com personagem em pé voltado à direita para uso em visão lateral, rosto
reconhecível, pés e mãos inteiros, contornos formados por pixels quadrados e fundo transparente real.
Sem cenário, texto, nome ou moldura. Mantenha margem ao redor do corpo.
Esta imagem será a referência principal de todas as animações de João Miguel.
```

## 3. Luna — aparência principal

```text
Use as referências anexadas para criar Luna como personagem jogável do mesmo
jogo de plataforma 2D. Preserve sua própria identidade, cabelo, tom de pele,
aparência da idade e proporções observadas. Traços essenciais: [PREENCHER].
Roupa escolhida: [PREENCHER]. Não transfira características de João Miguel.

Siga a direção de arte anexada e o mesmo acabamento do elenco. Corpo inteiro,
em pé, voltada à direita para visão lateral, rosto reconhecível, mãos e pés
visíveis, fundo transparente real. Sem cenário, texto ou acessórios não pedidos.
Será a referência principal das animações e do retrato de Luna.
```

## 4. Lucas o Engenheiro — aparência principal

```text
Crie Lucas o Engenheiro como personagem jogável 2D usando suas referências
anexadas. Preserve rosto, cabelo, tom de pele, aparência da idade e proporções.
Traços essenciais: [PREENCHER]. Roupa e acessórios confirmados: [PREENCHER].
O nome do personagem não é motivo para acrescentar capacete, ferramentas ou
uniforme sem essas referências ou instruções. Não o transforme em criança
se as referências não mostrarem isso.

Siga a mesma direção pixel art de baixa resolução do elenco. Corpo inteiro em pé voltado à
direita, visão lateral, rosto reconhecível, contornos formados por pixels quadrados e margem ao redor.
Fundo transparente real, sem cenário, texto ou nome dentro da arte.
Será a imagem principal para gerar suas animações de plataforma.
```

## 5. Samara — identidade pessoal e look Nude Project

```text
Crie Samara como personagem de plataforma em PIXEL ART de baixa resolução,
com aparência dos jogos clássicos de 16 bits. Imagem 1: foto pessoal da Samara,
referência exclusiva de identidade, rosto e cabelo. Preserve cabelo escuro
ondulado com franja, aparência adulta, tom de pele e traços reconhecíveis.

Imagem 2: referência EXCLUSIVA de roupa Nude Project. Vista Samara com o
moletom marrom chocolate oversized, capuz abaixado, bolso canguru, jeans azul
claro largo com cordão e sapatos baixos escuros mostrados. Não copie o rosto
ou cabelo da modelo do catálogo. Não use vestido. Mangas cobrem a tatuagem.

Corpo inteiro voltado para a direita, proporções compactas de plataforma,
cabeça reconhecível, mãos e pés inteiros. Meta: personagem de cerca de 32×48
pixels em célula lógica de 64×64, ampliado com pixels quadrados nítidos.
Paleta reduzida, poucas sombras sólidas, contorno em degraus. Sem pintura
suave ou gradientes. Marca do peito apenas como pequeno detalhe simplificado.
Fundo uniforme, sem quadriculado desenhado, cenário ou legendas.
```

## 6. Animação de um personagem

Usar uma ação e um personagem por geração, anexando a imagem principal correspondente. O exemplo pede caminhada; adaptar ação e número de quadros conforme o contrato de arte.

```text
Use a referência principal anexada de [PERSONAGEM] para criar os 8 quadros
sucessivos de uma caminhada lateral para a direita, em ciclo contínuo.
Preserve exatamente o desenho escolhido do rosto, cabelo, roupa, paleta e
proporções do personagem. Mude apenas a pose necessária ao movimento.

Organize em grade regular de 4 colunas por 2 linhas, leitura da esquerda
para a direita e de cima para baixo, células quadradas iguais. O contrato
final prevê células de 64×64 pixels lógicos; mantenha enquadramento e escala
consistentes para preparação posterior se a saída não tiver esse tamanho.

Fundo transparente real, sem rótulos ou números. Não corte partes do corpo;
mantenha baseline e pivot compatíveis. Alternância natural de braços e pernas,
sem membros extras ou duplicados. O último quadro deve conectar ao primeiro.
Sem deslocamento do personagem pela folha: a engine fará o deslocamento.
```

Uma grade pedida no prompt pode sair irregular. Conferir quadros individualmente e testar o ciclo. Não chamar a folha de pronta antes de revisar transparência, recorte e continuidade.

## 7. Corrigir um quadro

```text
Compare o quadro anexado com a referência principal de [PERSONAGEM].
Corrija somente estas inconsistências: [LISTAR]. Preserve o restante da pose,
roupa, rosto, paleta, escala e enquadramento. Mantenha o apoio/pivot indicado,
transparência real e todas as partes dentro da célula. O quadro deve encaixar
na sequência anexada sem mudança de identidade ou tamanho.
```

## 8. Terreno e plataformas

```text
Crie as peças de terreno do Jardim das Letras seguindo a direção 2D anexada:
chão central repetível, borda esquerda, borda direita, preenchimento de terra
e plataforma suspensa. Visão lateral, sem perspectiva isométrica.

Use grade regular com peças alinhadas para preparação em tiles de 16×16 pixels lógicos.
Superfícies de contato nítidas, emendas horizontais coerentes e paleta uniforme.
Transparência real fora das peças. Sem personagem, letras ou cenário completo.
A geometria de colisão será configurada no jogo, separada da ilustração.
```

## 9. Fundos em camadas

```text
Crie somente a camada [CÉU / MONTANHAS / VEGETAÇÃO DISTANTE] de um cenário 2D
lateral do Jardim das Letras. Siga a direção visual anexada. A camada deve
combinar com as outras sem incorporar chão jogável, personagens ou interface.

Composição horizontal repetível, horizonte consistente e contraste moderado.
Para montanhas/vegetação, use transparência real fora das formas; para céu,
um fundo contínuo. Deixe a região de ação visualmente tranquila. Sem texto.
```

Gerar cada camada em arquivo separado; uma imagem achatada não equivale a camadas independentes para rolagem.

## 10. Retratos, interface e itens

```text
Crie [UM RETRATO / UM ÍCONE / UM SUPORTE DE LETRA / UM ITEM DE VELOCIDADE]
para a plataforma 2D da direção anexada. Se for retrato, use a referência
principal de [PERSONAGEM], preservando identidade e enquadramento equivalente
aos outros retratos. Se for item, faça uma silhueta facilmente reconhecível.

Fundo transparente real, contraste claro em tamanho pequeno, acabamento
coerente com o jogo. Não desenhe nome, letras ou instruções dentro da imagem:
esses textos serão inseridos pela interface. Produza uma peça por arquivo.
```

Repetir para os quatro retratos e todos os itens necessários. Para efeitos animados, usar o contrato de sequência do prompt 6 com a ação apropriada.

## 11. Primeiro protótipo inteiramente sem sensor

```text
Leia README.md e docs/01-visao-e-experiencia.md, docs/04-arte-e-personagens.md
e docs/05-arquitetura.md. Implemente a primeira fase de plataforma 2D em Godot 4
estável, verificando versão e documentação de APIs via Context7.

Use visão lateral, câmera que acompanha, movimento esquerda/direita, salto,
plataformas, uma atividade de letra, coleta única, checkpoint e retorno ao cair.
Proponha CharacterBody2D, Camera2D, AnimatedSprite2D/SpriteFrames e terreno 2D.
Use formas temporárias onde a arte ainda estiver pendente, sem apresentá-las
como arte final ou semelhança real. Não gere os personagens sem suas referências.

Crie catálogo e seleção de João Miguel, Luna, Lucas o Engenheiro e Samara,
separados do perfil de progresso. Menus e partida devem funcionar por teclado
e controle compatível. Sem sensor é o modo padrão: não exigir receptor,
conexão, permissões ou calibração para começar ou concluir.

Prepare a camada de entrada para receber futuramente salto por sensor.
Inclua movimento, salto, poder, pausa, confirmação, voltar e repetir instrução.
Letras e nomes são texto real. Toda arte final deverá vir do ChatGPT Image 2.5
solicitado; não trocar o modelo sem informar indisponibilidade e resolver isso.

Entregue projeto executável e evidências de verificação. Informe claramente
quais recursos e imagens ainda são temporários ou não foram implementados.
```

## 12. Sensor como opção adicional

```text
Leia docs/02-sensor-e-movimentos.md e docs/05-arquitetura.md.
Hardware confirmado: [SENSOR, MÓDULO, PLACA]. Sistema: [PREENCHER].
Integração anterior: [ANEXAR OU INDICAR]. Não invente pinagem ou tensão.

Implemente o detector opcional com calibração, registro, supressão de duplicatas
e estados de conexão. Comece em bancada com adulto; compare salto com passos,
agachamento e ajuste do dispositivo. Dispare cedo o suficiente para jogar.
Integre o evento à mesma intenção de salto do botão; eventos coincidentes
não devem produzir dois saltos. Registre sessão e identificador do evento.

O menu permite Sem sensor e Com sensor. Fora do modo corporal, não inicialize
nem aceite eventos do receptor. Desconexão corporal pausa com opção de continuar
sem sensor. Trocar modo preserva perfil, personagem, checkpoint e progresso,
limpa filas e não exige reiniciar o jogo. Entrar no modo corporal pede calibração.

Meça detecção, falsos comandos e latência com método explícito e dados separados
dos usados no ajuste. Não declare validação infantil sem teste real supervisionado.
Verifique que todas as fases e quatro personagens continuam acessíveis sem sensor.
```

## 13. Atividades de aprendizagem

```text
Leia docs/03-aprendizagem.md. Crie cinco atividades em português brasileiro
para [HABILIDADE], considerando o repertório informado: [PREENCHER].
Entregue objetivo, instrução, alternativas, resposta, pistas, pré-requisitos,
feedback e ilustração necessária. Separe nome da letra, som, sílaba e palavra.

Não determine dificuldade só pelo número de sílabas. Diferencie escolha errada,
falha motora e acerto com ajuda. Dê tempo para escolher na fase lateral.
Todas as atividades devem funcionar por botão e sensor, com qualquer um dos
quatro personagens. A ilustração será criada no ChatGPT Image 2.5 e o texto
será revisado e renderizado no jogo. Marque dúvidas para revisão humana.
```

## 14. Revisão final

```text
Leia a documentação e inspecione a fase real. Verifique os quatro personagens,
semelhança às referências, animações, terreno, câmera lateral, áudio e letras.
Teste menus e fase completa sem sensor, por teclado e controle compatível.
Teste troca de modo, perda de conexão corporal, continuação por botão, eventos
atrasados, checkpoint e progresso. Ausência de sensor fora do modo corporal
não pode interferir. Nenhuma recompensa pode depender do dispositivo.

Confira o registro da arte: referências, prompts e modelo efetivamente usado.
Não deduza que foi Image 2.5 só pelo nome de um arquivo. Relate problemas
reproduzíveis, evidências e correções por impacto. Diferencie teste executado
de hipótese e observação ainda pendente com a família.
```

## Regra visual comum aos prompts

Aplicar pixel art de baixa resolução também a Luna, João Miguel, Lucas, terreno, itens, retratos e fundos. Usar as imagens `pixel-master-v1.png` como bases de estilo, não as versões ilustradas históricas. As ampliações geradas ainda precisam de verificação da grade e transparência para uso na engine. Os prompts exatos deste lote estão no registro de produção.

## Prompts executados: retratos e objetos

O [Lote 03](../production/LOTE-03.md) registra as oito gerações de retratos e objetos, com referências específicas por personagem e uma peça por arquivo. Os prompts exatos estão em [lote-03-jobs.json](../production/lote-03-jobs.json) e individualmente na pasta de produção. Todos retornaram RGBA com transparência real, sem que isso confirme normalização de pixels ou integração.
