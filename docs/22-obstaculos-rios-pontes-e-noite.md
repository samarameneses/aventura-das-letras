# Obstáculos, rios, pontes e noite — versão 0.12.0

8 de setembro de 2026.

## Como ficou a brincadeira

Os percursos têm rios rasos, poças de lava, pontes de madeira e troncos baixos. As letras mantêm suas posições. Os obstáculos novos aparecem nos espaços entre as atividades; o rio inicial apresenta a água antes dos primeiros desafios.

- **Lava:** poças animadas para saltar. O contato nos pés tira uma vida, mostra pequenas chamas por 1,2 segundo e coloca o personagem numa margem segura próxima. No Speed Run, ele continua na margem adiante. Há 2,5 segundos de proteção contra dano repetido. Não aparece anúncio, mensagem de erro ou tela de reinício. As descobertas e os poderes são mantidos. Ao acabar a última vida, os corações se renovam silenciosamente, conforme o comportamento anterior.
- **Rio raso:** atravessar molha os pés e produz gotinhas. Não tira vidas nem atrasa o personagem. Os pés secam cerca de dois segundos após sair da água.
- **Ponte:** piso sólido de madeira, tábuas, postes e corda sobre um intervalo no chão. É possível atravessá-la andando, sem gastar o poder de ponte de arco-íris. O poder existente continua funcionando no vão original.
- **Troncos:** pequenos obstáculos sólidos que pedem um salto.
- **Iluminação:** os trechos seguem a sequência dia, entardecer e noite. À noite, o cenário e o terreno recebem tons azulados, com lua e estrelas; personagens, letras e interface permanecem claros. A troca acontece ao avançar de fase, inclusive na aventura contínua.

A largura da lava é de 28 unidades do mundo, ajustada ao salto normal do personagem. As fases curtas podem ter menos tipos de obstáculos para preservar a aproximação do portal. Nenhum sensor é necessário; teclado, controle e botões mantêm as ações existentes.

## Implementação e progresso

Os elementos são desenhos nativos em pixel art e animações do Godot sobre os cenários existentes. Não foram geradas nem alteradas fotografias ou imagens raster nesta atualização. O cenário de noite reutiliza a arte existente com iluminação por cor.

O contato com lava é registrado como `lava_contact`, separado de erros nas respostas. Os recordes anteriores ficam preservados em `power_run_records`; os novos percursos usam `terrain_run_records`, para comparar tempos obtidos nas mesmas condições. O progresso das atividades é preservado. Os efeitos de água, fogo e proteção são temporários e congelam com a pausa.

## Verificações

- 84 verificações de terreno, incluindo travessia das 68 fases com todos os acertos, apenas saltos e sem dano, salto manual sobre lava, ponte física, pés molhados, iluminação e proteção contra dano repetido.
- 43 verificações de poderes e continuidade, 38 de Speed Run e 25 de fluxo sem interrupções.
- Capturas em janela nativa de dia, entardecer e noite, com rio, lava e ponte.
- Verificação adicional do pacote exportado antes de atualizar o aplicativo local.

Os testes usam perfis próprios na pasta `evidence`; não alteram o perfil familiar. O sensor físico não foi testado nesta atualização.

![Lava à noite](../evidence/v12-noite-lava.png)

![Ponte de dia](../evidence/v12-dia-ponte.png)
