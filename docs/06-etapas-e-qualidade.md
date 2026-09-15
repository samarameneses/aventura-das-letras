# Etapas de produção e critérios de qualidade

> Documento de planejamento. Estado implementado e evidências da versão 0.1.0 em [Entrega e sensor](10-entrega-e-sensor.md).


## Ordem recomendada

**Primeiro tornar a plataforma 2D divertida e inteiramente jogável sem sensor.** A integração corporal é uma etapa opcional que não bloqueia o desenvolvimento convencional. A versão completa deve incluir João Miguel, Luna, Lucas o Engenheiro e Samara, com arte produzida no ChatGPT Image 2.5 solicitado.

As faixas abaixo são estimativas autorais de esforço para alguém experiente, com disponibilidade regular. Não são orçamento ou compromisso de entrega. Referências pendentes, acesso ao modelo, consistência de animação, dispositivo final e aprendizado das ferramentas alteram o calendário.

| Etapa | Entrega | Estimativa preliminar | Critério para seguir |
| --- | --- | --- | --- |
| 0. Base e referências | Aparelho, direção de arte e fichas dos quatro | 1–2 dias após informações disponíveis | Destino conhecido; produção visual aguarda referências e acesso ao modelo |
| 1. Protótipo sem sensor | Percurso lateral, movimento, salto, letra e checkpoint | 3–7 dias | Rodada completa usando apenas teclado; verificar controle compatível |
| 2. Brincadeira e aprendizagem | Instrução, escolhas, ajuda e progresso | 1–2 semanas | Distinguir respostas incorretas de falhas de movimento |
| 3. Arte e animação do elenco | Quatro personagens, terreno, fundos e interface | 2–5 semanas | Semelhança revisada; animações estáveis dentro do jogo |
| 4. Sensor opcional | Conexão, calibração, detecção e troca de modo | 1–3 semanas, a reestimar com dados | Modo corporal utilizável; convencional continua independente |
| 5. Versão familiar polida | Executável, poderes, ajustes, áudio e recuperação de falhas | 1–3 semanas | Testes de uso completos no aparelho final |
| 6. Expansão | Sílabas, palavras, números e novas fases | Ciclos próprios | Cada atividade mantém clareza e acesso pelos dois modos |

A produção visual e a prova do sensor podem ser organizadas em frentes independentes quando houver recursos. Isso não exige delegação automática. Pensar em semanas a alguns meses para a primeira versão bem acabada e reestimar após as provas, sem prometer a escala de uma franquia inteira.

## Etapa 0 — Confirmar a base

O formato 2D, a referência de plataforma retrô, os quatro personagens, o Image 2.5 solicitado e o modo sem sensor já estão definidos. As referências já foram recebidas e o lote atual de pixel art está gerado. Faltam aparelho e repertório das crianças. Conferir o acesso efetivo ao modelo antes de gerar; não substituir silenciosamente.

Hardware e código do projeto de carros podem ser identificados depois, sem bloquear o protótipo sem sensor. Não comprar peças antes de conhecer o kit existente.

## Etapas 1 e 2 — Provar o jogo e a atividade

Construir com formas temporárias: chão, plataformas, personagem, câmera lateral, salto, coleta única e retorno. As formas de desenvolvimento não representam a arte final. A partida deve abrir sem receptor e sem tentar conectar Bluetooth.

Acrescentar instruções faladas, duas alternativas por escolha, tolerância de salto e registro de ajuda. O jogador precisa escolher antes de coletar. Testar menus e partida inteiramente com teclado e, depois, controle compatível. Manter nomes dos quatro no catálogo mesmo enquanto a arte estiver pendente; não apresentar placeholders como retratos reais.

## Etapa 3 — Produzir a arte no Image 2.5

Após receber referências, gerar uma imagem principal para cada personagem. Validar uma animação de caminhada em jogo antes de produzir o conjunto. Criar sprites, retratos, terreno, fundos, objetos, efeitos e interface com o mesmo modelo solicitado e linguagem visual.

Conferir transparência, enquadramento, apoio dos pés, escala, rosto, roupa e continuidade. O plano inicial de 30 quadros por personagem implica 120 no elenco, além de retratos e cenário; são quadros finais, não estimativa de chamadas ao gerador. Refazer os inconsistentes.

Entrega: primeira fase com os quatro personagens selecionáveis e arte próxima do acabamento pretendido. Letras e palavras continuam texto revisado, sobre suportes ilustrados.

## Etapa 4 — Integrar o sensor opcional

Identificar placa, módulo e comunicação anterior. Testar com adulto em bancada; ajustar o detector e medir falsos eventos e atraso. Integrar à mesma intenção de salto usada pelo botão.

A tela de conexão sempre oferece seguir sem sensor. Desconexão no modo corporal pausa com opção de continuar convencionalmente. Fora dele, ignorar o dispositivo. Caso o detector não fique bom, a versão sem sensor continua utilizável e sua disponibilidade não deve ser bloqueada.

## Etapa 5 — Polir e distribuir localmente

Revisar os quatro personagens em toda a fase; acrescentar velocidade virtual, volumes separados, remapeamento, troca de modo, salvamento e recuperação de checkpoint. Testar executável no aparelho e tela reais. Referências pessoais e registros de desenvolvimento ficam fora do pacote final.

## Testes de aceitação

| Área | Teste | Resultado esperado |
| --- | --- | --- |
| Independência do hardware | Abrir sem sensor/receptor instalado | Menu e partida acessíveis, sem erro de conexão |
| Elenco | Escolher os quatro em ambos os modos | Aparência correta; mesmas oportunidades |
| Teclado | Menus, movimento, salto, poder, pausa e chegada | Concluir sem outros dispositivos |
| Controle | Repetir o fluxo em controle compatível | Nenhuma etapa obriga usar teclado |
| Animações | Parar, andar, correr, subir, cair e pousar | Sem troca de roupa, tremor de escala ou colisão inconsistente |
| Sensor | Dados de validação separados dos usados no ajuste | Detecção e falsos eventos documentados |
| Duplicação | Repetir evento e coincidir botão/gesto | Uma intenção de salto |
| Troca de modo | Alternar no menu de pausa | Preservar perfil, personagem, checkpoint e progresso |
| Desconexão corporal | Desligar e continuar sem sensor | Retomada sem saltos atrasados |
| Desconexão convencional | Desligar sensor fora do modo corporal | Nenhuma interrupção |
| Física | Cair e retornar | Posição válida, velocidade zerada, sem coleta duplicada |
| Aprendizagem | Erro de escolha, ajuda e erro motor | Registros e feedback distintos |
| Persistência | Fechar/reabrir e interromper gravação | Recuperar progresso válido |
| Tela final | Rodar executável com cena completa | Fluidez, resposta e letras legíveis |

Automatizar regras de progresso, deduplicação e troca de modo quando o código existir. Semelhança e conforto precisam também de observação humana. Não foram executados testes de jogo nesta etapa documental.

## Recursos e próximos passos

Godot usa licença MIT. O custo de imagens depende do acesso já disponível; nenhum preço foi cotado. Os principais esforços são programação, geração e revisão de arte, áudio, conteúdo e teste do sensor opcional. Produzir imagens por IA não elimina a preparação das animações.

**Próximo passo técnico:** protótipo 2D sem sensor. **Próximo passo artístico:** normalizar o lote de pixel art, obter transparência e criar um novo ciclo piloto pixelado; a ferramenta usada não confirmou o identificador 2.5. São trabalhos que não precisam bloquear um ao outro.

## Correção de direção aplicada

A arte atual é pixel art inspirada nos jogos clássicos de plataforma. Samara usa moletom marrom e jeans largo da Nude Project. A caminhada ilustrada anterior ficou como histórico; produzir e validar o novo ciclo pixelado antes de multiplicar quadros. Verificar grade lógica, cores sólidas e escala consistente além dos testes já listados.
