# Lote 03 — retratos e objetos da primeira fase

Oito novas imagens em pixel art, seguindo os personagens já definidos. Este lote acrescenta retratos para a seleção e objetos do Jardim das Letras. Não substitui as seis bases anteriores em pixel art.

| Imagem | Arquivo |
| --- | --- |
| Retrato — João Miguel | [Abrir](../assets/portraits/joao_miguel/portrait-pixel-v1.png) |
| Retrato — Luna | [Abrir](../assets/portraits/luna/portrait-pixel-v1.png) |
| Retrato — Lucas o Engenheiro | [Abrir](../assets/portraits/lucas_engenheiro/portrait-pixel-v1.png) |
| Retrato — Samara | [Abrir](../assets/portraits/samara/portrait-pixel-v1.png) |
| Suporte de letra | [Abrir](../assets/items/letter-carrier-pixel-v1.png) |
| Poder de velocidade | [Abrir](../assets/items/speed-item-pixel-v1.png) |
| Ponto de retorno | [Abrir](../assets/objects/checkpoint-pixel-v1.png) |
| Portal de chegada | [Abrir](../assets/objects/finish-portal-pixel-v1.png) |

[Ver galeria atual](GALERIA.html#lote-03) · [Prompts exatos](prompts/) · [Manifesto](../assets/manifest.json)

## Decisões visuais e uso

- Os quatro retratos usam a imagem principal de cada personagem como referência de identidade, roupa e estilo. Samara conserva o moletom marrom do look Nude Project. O retrato mostra cabeça e ombros.
- O suporte de letra tem uma moldura dourada com centro claro vazio. A letra será texto real sobreposto pelo jogo; não há glifo gerado na imagem. Sílabas e palavras podem exigir suportes mais largos em um próximo lote.
- O tênis turquesa com raio representa o poder temporário de velocidade, disponível para qualquer personagem e modo de controle.
- A bandeira turquesa com seta de retorno é uma proposta de checkpoint ativado. Seu comportamento de salvar e restaurar posição ainda será implementado; a variante inativa está pendente.
- O arco dourado com estrela é a proposta de chegada da fase. O interior azul é opaco; a transparência fica fora do objeto.

## Verificação e limites

Todos os oito PNGs têm 1254×1254 pixels, modo RGBA e canal alpha com valores entre 0 e 255: a transparência externa é real. As cópias no projeto têm o mesmo hash dos arquivos gerados, e os originais foram preservados. As oito imagens foram inspecionadas visualmente; não contêm nomes ou conteúdo pedagógico gravado.

São bases estáticas com aparência pixelada ampliada. A saída ainda apresenta suavização e variação tonal dentro de alguns blocos; grade nativa, paleta reduzida, bordas e enquadramento comum dos retratos precisam de normalização. A transparência confirmada não significa que estejam prontas para integrar. Não foram validados leitura em tamanho pequeno, colisões, animações ou comportamento no jogo.

## Geração e rastreabilidade

Foi usada a ferramenta de geração integrada do ChatGPT, `image_gen`, com uma chamada por imagem. O modelo efetivo não é exposto pela interface; portanto, a versão solicitada ChatGPT Image 2.5 continua não confirmada. Não foi usada uma API ou ferramenta de geração alternativa.

Os prompts deste lote estão nos oito arquivos identificados no manifesto pelo campo `prompt_file`. O arquivo lote-03-jobs.json — registro local não distribuído (`production/lote-03-jobs.json`) também reúne prompts, referências e caminhos originais.

## Continuidade

1. Normalizar a grade e a escala de personagens, retratos e itens, preservando a transparência dos novos arquivos.
2. Preparar repouso e caminhada de João Miguel como ciclo piloto, antes de multiplicar animações do elenco.
3. Criar estados de checkpoint, efeitos de coleta e painéis da interface quando os primeiros testes definirem suas dimensões.
4. Validar no protótipo sem sensor; a mesma arte será usada no modo opcional com sensor.
