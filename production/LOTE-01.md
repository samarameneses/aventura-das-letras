# Produção de arte — lote inicial

## Entregas

- Referências: quatro originais HEIC copiados e renomeados, com conversões PNG e integridade verificada.
- Personagens: João Miguel, Luna, Lucas o Engenheiro e Samara, cada um em uma imagem principal de corpo inteiro.
- Ambiente: fundo do Jardim das Letras e folha com seis propostas de terreno/plataforma.
- Animação: folha de estudo com oito poses de caminhada de João Miguel.

[Ver a galeria visual](GALERIA.html) · Referências organizadas — registro local não distribuído (`references/characters/README.md`) · [Manifesto dos assets](../assets/manifest.json)

## Estado real dos arquivos

Este lote contém **artes de personagem e bases para produção**, não um pacote de sprites animados pronto para integrar. O fundo do jardim é uma imagem opaca única; camadas independentes de paralaxe e emendas de repetição ainda não foram validadas.

Os PNGs gerados são RGB e não possuem canal alpha. A primeira tentativa de João Miguel e uma tentativa de correção retornaram quadriculado desenhado. Essas versões foram marcadas como rejeitadas/não utilizáveis; a imagem principal atual de João Miguel é `master-v2.png`, com fundo branco. Os outros personagens e a folha de terreno também têm fundo branco e precisam de recorte com transparência.

A folha de caminhada apresenta oito poses, mas contém repetição de poses, variação de apoio/escala e alternância das pernas a corrigir. Não é um ciclo validado. Não foram extraídos ou normalizados quadros nem executados testes no Godot.

## Ferramenta e versão

Foi usada a **geração nativa integrada do ChatGPT (`image_gen`)**, incluindo as correções visuais. Não foi usada API/CLI alternativa. O requisito informado é ChatGPT Image 2.5; a interface utilizada não expõe o identificador do modelo nem permite selecionar essa versão. Por isso os metadados registram a versão efetiva como **não informada**, sem afirmar confirmação de 2.5.

Os prompts exatos de todas as gerações estão em [prompts](prompts/). O manifesto relaciona referência, prompt, arquivo, tamanho, ferramenta, revisão e estado de integração. Os nomes dos arquivos não comprovam a versão do modelo.

## Decisões de aparência

João Miguel: cabelo curto escuro e despenteado, sorriso e blusa verde; parte inferior completada com calça azul-marinho e tênis claros como proposta artística.

Luna: cabelo loiro comprido, presilha, blusa listrada rosa/vinho com coração, calça rosa e tênis claros.

Lucas o Engenheiro: óculos arredondados, cabelo escuro, barba, camiseta marrom, calça clara e tênis escuros. Não recebeu capacete ou ferramentas. O moletom com texto que ele segura na foto não foi incorporado.

Samara: cabelo escuro ondulado com franja, vestido marrom, brincos, colar e tatuagem visível. Comprimento final do vestido e tênis claros são propostas, pois a referência não mostra todo o corpo.

As quatro imagens foram inspecionadas visualmente; a semelhança ainda pode ser refinada pela família. São as mesmas aparências para os modos com e sem sensor.

## Continuidade

1. Refinar semelhança e detalhes de roupa caso a família solicite.
2. Obter transparência real e normalizar tamanho, pivôs e margens sem degradar o desenho.
3. Corrigir o ciclo piloto, testar na engine e então produzir as demais animações.
4. Recortar e validar terreno e produzir itens, retratos e interface.
5. Integrar primeiro ao protótipo 2D completo por teclado/controle; depois ao sensor opcional.
