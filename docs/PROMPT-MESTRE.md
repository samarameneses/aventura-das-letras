# Crie seu próprio jogo do zero

Use este prompt como ponto de partida para criar uma aventura educativa com seus próprios personagens. Ele adapta a ideia que deu origem à Aventura das Letras para outras famílias, educadores e criadores.

## Como usar

1. Copie o bloco abaixo para uma nova conversa com seu assistente de desenvolvimento.
2. Substitua os campos entre colchetes. Você pode incluir quantos personagens quiser e usar pessoas reais ou personagens inteiramente fictícios.
3. Descreva as características e roupas de cada personagem. Se usar fotografias, compartilhe apenas referências autorizadas e mantenha-as fora do repositório público.
4. Informe o computador em que pretende jogar, a faixa etária e se já tem algum sensor. Você pode começar inteiramente sem hardware.
5. Peça primeiro a avaliação e o plano; depois avance pela primeira fase funcional e amplie o projeto em etapas.

No projeto original, os personagens eram João Miguel, Luna, Lucas, o Engenheiro, e Samara. São apenas um exemplo de elenco: troque os nomes, as aparências e os papéis pelos personagens da sua aventura.

## Prompt mestre — copie e personalize

```text
Quero criar do zero um jogo educativo com estética 8-bit em pixel art e
acabamento profissional para [PÚBLICO E FAIXA ETÁRIA], combinando aprendizado,
exploração e movimentos físicos opcionais.

O nome provisório será [NOME DO JOGO]. O idioma será [IDIOMA]. Pretendo jogar
em [SISTEMA OPERACIONAL / DISPOSITIVO]. Minha experiência com programação é
[NÍVEL DE EXPERIÊNCIA] e meu orçamento inicial é [ORÇAMENTO OU RESTRIÇÕES].

PERSONAGENS
Os personagens principais selecionáveis serão:
- [PERSONAGEM 1]: [APARÊNCIA, CABELO, ROUPA, PROPORÇÕES E TRAÇOS IMPORTANTES].
- [PERSONAGEM 2]: [APARÊNCIA, CABELO, ROUPA, PROPORÇÕES E TRAÇOS IMPORTANTES].

O jogo também poderá contar com familiares ou outros personagens:
- [PERSONAGEM 3]: [PAPEL, APARÊNCIA E ROUPA].
- [PERSONAGEM 4]: [PAPEL, APARÊNCIA E ROUPA].

Adapte a quantidade de personagens ao meu elenco. Para pessoas reais,
preserve suas características observáveis e sua aparência de idade ao
adaptá-las para pixel art. Para personagens fictícios, siga a descrição
fornecida. Não misture identidades entre referências. Separe referências
de identidade, roupa e estilo visual. Use somente imagens autorizadas e
mantenha fotografias pessoais fora dos arquivos destinados à publicação.

DIREÇÃO VISUAL E FERRAMENTAS
Quero usar a geração de imagens do ChatGPT para criar sprites e recursos
visuais. Minha preferência inicial é ChatGPT Image 2.5, junto das ferramentas
que você recomendar. Antes de planejar a produção, confirme qual modelo está
realmente disponível. Se a versão solicitada não estiver disponível ou não
puder ser identificada, explique isso e proponha uma alternativa, sem
atribuir a geração a um modelo não confirmado.

Defina uma identidade visual própria de plataforma 2D com visão lateral,
pixel art de baixa resolução, pixels nítidos, paleta limitada, escala de
personagens consistente e boa leitura dos obstáculos. Trate 8-bit como a
direção estética desejada e explique quais limites de resolução, cores e
animação adotaremos na prática. Mantenha letras, números e palavras como
texto real do jogo, separado das imagens.

A PROPOSTA INCLUI
1. Aventura: andar, pular, explorar, retornar ao percurso após quedas e
   desbloquear poderes, como supervelocidade.
2. Aprendizado progressivo: coletar letras ao pular e evoluir para sílabas,
   palavras monossílabas, dissílabas e desafios com números. Adapte a
   progressão à faixa etária e ao conhecimento inicial informado.
3. Interação física opcional: utilizar um sensor MPU-9250 para detectar os
   saltos reais da criança e reproduzi-los no jogo. Meu hardware disponível
   é [PLACA, SENSOR E COMPONENTES, OU "AINDA NÃO TENHO"].
4. Modo sem sensor completo: permitir jogar com teclado, botões na tela ou
   controle compatível, com os mesmos personagens, conteúdo e recompensas.
5. Evolução por etapas: começar com uma fase pequena e funcional, ampliando
   depois os cenários, desafios e conteúdos educativos.

AVALIAÇÃO E PRIMEIRA VERSÃO
Avalie a viabilidade da ideia e indique o melhor caminho para executá-la.
Recomende o motor de jogo, as ferramentas para criar e animar os sprites e
a forma de integrar o sensor. Justifique as escolhas considerando meu
computador, experiência, orçamento e facilidade de manutenção.

Confirme o modelo correto do sensor e da placa com documentação técnica e
identificação do hardware antes de definir pinagem ou alimentação. Não
presuma que módulos visualmente semelhantes sejam equivalentes. Explique
a precisão esperada, as limitações, os falsos positivos, a calibração e a
latência; diferencie hipóteses e simulações de resultados medidos em uso real.
Explique também cuidados para uso seguro por crianças, supervisão, fixação,
espaço para movimento e uma alternativa confortável sem saltos físicos.

Proponha uma primeira versão jogável para validar a experiência de pular
para coletar letras: uma fase curta, poucos obstáculos, retorno a um ponto
seguro, feedback acolhedor e progressão pedagógica adequada. Valide primeiro
o jogo sem sensor; depois teste a integração em bancada e, com supervisão,
a interação física. Defina critérios observáveis para decidir se podemos
avançar de etapa, incluindo comportamento quando a conexão cair.

Inclua um plano de desenvolvimento e prompts para gerar personagens,
cenários, objetos e animações com consistência visual em 8-bit. Especifique
as folhas de sprites, as dimensões lógicas, a transparência real, as margens,
o alinhamento dos pés e os estados necessários: parado, andando, correndo,
pulando, caindo, pousando e comemorando. Explique como preparar, revisar e
integrar os recursos ao motor, sem assumir que uma imagem gerada já seja um
sprite pronto para uso.

DOCUMENTAÇÃO E ENTREGA
Documente tudo em arquivos Markdown (.md), organizando o conceito, as
tecnologias, a integração do sensor, os prompts e as etapas de execução.
Use uma estrutura clara, por exemplo:
- README.md: apresentação, requisitos, instalação e como jogar.
- docs/01-conceito.md: público, personagens, experiência e objetivos.
- docs/02-tecnologias.md: motor, ferramentas e justificativas.
- docs/03-aprendizagem.md: conteúdos, progressão e revisão pedagógica.
- docs/04-arte-e-personagens.md: direção visual e guia de consistência.
- docs/05-sensor.md: hardware, comunicação, calibração e limitações.
- docs/06-prompts.md: prompts reutilizáveis para todos os recursos visuais.
- docs/07-etapas-e-testes.md: plano incremental, critérios e resultados.

Registre o que está implementado, o que foi testado e o que ainda precisa
ser validado. Entregue instruções reproduzíveis para que outra pessoa possa
abrir o projeto. Nunca inclua senhas de Wi-Fi, chaves de API, tokens de
pareamento ou dados pessoais nos arquivos públicos; use exemplos sem
segredos e configurações locais ignoradas pelo Git.

Comece apresentando sua avaliação de viabilidade, as dúvidas essenciais,
a proposta da primeira versão jogável e o plano de desenvolvimento.
```

## Continuar por etapas

Depois de revisar o plano, você pode pedir:

> Implemente a primeira fase do plano aprovado, começando pelo modo sem sensor. Crie os arquivos do projeto, documente como executar e valide movimento, salto, coleta de letras e retorno após quedas. Use o elenco e a direção visual que definimos. Registre as pendências da próxima etapa.

Para a arte, use o guia de consistência criado para o seu elenco antes de solicitar novas animações. Para o sensor, avance somente depois da identificação do hardware e dos testes de bancada previstos no plano.

## Criar do zero ou adaptar este projeto?

- **Criar do zero:** use o prompt acima em uma conversa e pasta novas. O nome, o elenco, o motor e as escolhas técnicas poderão ser definidos para a sua proposta.
- **Adaptar a Aventura das Letras:** faça um fork e siga o [README](../README.md) e o [guia de contribuição](../CONTRIBUTING.md). O jogo existente, seus recursos e sua documentação já oferecem uma base para modificações.

Para consultar exemplos de produção deste jogo, veja os [prompts de arte](history/07-prompts.md), o [registro de produção](../production/README.md) e o [guia do sensor](SENSOR.md). Esses exemplos mostram decisões específicas deste projeto; personalize-os para o seu elenco e ambiente.
