# Produção de arte — versão jogável 0.1.0

A direção atual é pixel art de plataforma lateral. João Miguel, Luna, Lucas o Engenheiro e Samara foram criados a partir das referências pessoais fornecidas. Samara usa moletom marrom, jeans claro largo e sapatos escuros, conforme o look Nude Project. A referência de roupa não substituiu o rosto da Samara.

[Galeria com animações](GALERIA.html) · [Manifesto](../assets/manifest.json) · [Prompts de referência](prompts/) · [Jogo e testes](../docs/history/10-entrega-e-sensor.md)

Para começar uma aventura com seus próprios personagens, consulte o [prompt mestre personalizável](../docs/PROMPT-MESTRE.md).

Os textos públicos dos prompts e do manifesto passaram por revisão editorial para descrever a estética em termos genéricos de pixel art e plataforma retrô. Eles servem como referências reutilizáveis; não são transcrições literais de todas as solicitações originais. Os arquivos de imagem permanecem os mesmos.

## Conjunto atual

35 imagens selecionadas na direção pixelada, das quais **30 estão integradas ao jogo**. As cinco bases restantes (quatro corpos inteiros e a folha conceitual de terreno) orientam a arte, sem serem usadas como sprites finais. A versão ilustrada lisa anterior permanece histórica.

Para cada personagem: 4 quadros parados, 8 de caminhada, 8 de corrida, 6 de ciclo de salto (subida/queda/pouso) e 4 de comemoração. São 20 folhas e 120 quadros no total, com transparência real. Retratos, objetos, fundo e bloco de grama completam a fase.

Os PNGs originais foram copiados sem alteração de pixels. A leitura do alpha localiza as regiões dentro das células; o jogo usa AtlasTexture com essas regiões e pivô nos pés. Os metadados estão em `game/art/animations.json`. A janela padrão amplia o mundo 320×180 em três vezes, usando nearest. As imagens têm aparência pixelada, mas ainda não representam uma paleta e grade nativa uniforme certificadas por acabamento manual.

## Ferramenta e procedência

Todas as novas imagens foram geradas pela ferramenta nativa integrada `image_gen`. Ela não permite selecionar nem consultar a versão do modelo. **ChatGPT Image 2.5 foi solicitado pela família, mas sua utilização efetiva não pode ser confirmada.** O manifesto registra essa distinção, a referência, o prompt, o destino, a transparência e o hash de cada original. Os 30 registros `game_ready: true` foram integrados e carregados no jogo.

Três tentativas de idle da Samara apresentaram fundo quadriculado opaco e foram rejeitadas. A versão aceita foi gerada a partir da folha de comemoração com alpha real. O nome de produção é `samara_idle_pixel_v4`, integrado no caminho estável `idle-pixel-v1.png`. Isso evita confundir uma aparência de transparência com um canal alpha de verdade.

As fotos e os originais HEIC permanecem em `references`. Não são incluídos em `release/Aventura.pck`. [Lote 01](LOTE-01.md) e [Lote 03](LOTE-03.md) documentam etapas anteriores; suas pendências não substituem o estado atual desta página.


## Atualização 0.4.0 — primavera e outono

Quatro panoramas novos, gerados com image_gen integrada e preservados sem edição em `assets/backgrounds`. Os 48 cenários do jogo usam composições distintas desses templates. Os jobs de geração ficam apenas no ambiente local; consulte os [prompts publicados](prompts/) · [Conteúdo e validação](../docs/history/13-palavras-e-estacoes.md).
