# Como contribuir

Você pode colaborar em português ou inglês. Não precisa ter um sensor para desenvolver ou testar o jogo.

## Primeiro contato

- Use Issues para erros reproduzíveis e propostas concretas.
- Use Discussions para dúvidas, ideias e relatos de uso sem dados pessoais.
- Consulte o [roadmap](ROADMAP.md) antes de iniciar uma mudança grande.
- Para falhas de segurança, siga [SECURITY.md](SECURITY.md).

## Fluxo de trabalho

1. Faça um fork e clone seu fork.
2. Crie uma branch descritiva, como `fix/menu-navigation`.
3. Importe `game/project.godot` no Godot 4.7.2 Standard e implemente uma mudança pequena e focada.
4. Execute `python3 tools/check_publication.py` e `python3 tools/run_tests.py` com Python 3.10+.
5. Verifique manualmente a tela ou interação alterada. Inclua captura do jogo para mudanças visuais, sem dados pessoais.
6. Abra um pull request descrevendo o problema, o comportamento novo e o que foi testado. Relacione a issue quando existir.

Se Godot não estiver no PATH, defina `GODOT_BIN` com o caminho do executável. Resultados temporários ficam em `evidence/` e não devem entrar no commit. Os testes de hardware e captura são complementares à suíte automática; descreva limitações e seu ambiente.

## Convenções

Preserve o estilo do arquivo editado e evite reformatações sem relação com a tarefa. Mantenha o conteúdo pedagógico em português brasileiro, com acentos e separação silábica revisados. Conteúdo fica em `game/content/`; a lógica fica em `game/scripts/`. Atualize a documentação quando mudar comandos ou comportamento.

O modo sem sensor deve continuar completo. Mudanças no detector precisam de casos que cubram saltos, falsos positivos e perda de conexão. Testes sintéticos não substituem testes físicos. Nunca inclua senhas, arquivos de pareamento, dumps da placa, gravações ou fotos de crianças em issues, commits ou logs públicos.

## Arte e autoria

Envie apenas material que você tenha direito de compartilhar, com fonte/licença registrada em `THIRD_PARTY_NOTICES.md` quando aplicável. Informe uso de ferramentas generativas e mantenha a procedência. Contribuições ao conteúdo próprio do projeto são feitas sob a licença MIT do repositório. Os mantenedores revisam os pull requests antes da integração.
