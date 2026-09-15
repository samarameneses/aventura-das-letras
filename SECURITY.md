# Segurança e privacidade

## Relatar uma vulnerabilidade

Use [Report a vulnerability](https://github.com/Sa-Meneses/aventura-das-letras/security/advisories/new) para enviar um relato privado aos mantenedores. Não publique credenciais ou detalhes exploráveis em uma issue pública. Inclua a revisão afetada, o impacto e passos mínimos para reprodução com valores fictícios.

A branch `main` recebe correções. Não há garantia de atendimento em prazo específico.

## Configurações locais

O modo comum não requer variáveis de ambiente nem API keys. `GODOT_BIN` é somente um caminho opcional para o executável. O sensor usa `firmware/aventura_esp32/config.h` e `firmware/local/` para credenciais de Wi-Fi e pareamento; ambos são ignorados pelo Git. Use `config.example.h` e gere um token próprio. Binários de firmware também podem conter senhas, por isso builds e dumps não são versionados.

O jogo salva perfis e progresso localmente. Não envie salvamentos, fotos de referência ou medições pessoais para o repositório. A suíte de testes usa dados sintéticos separados em `evidence/`.

O transporte Wi-Fi do sensor usa UDP com pareamento, sem criptografia. Destina-se a uma rede local confiável; não exponha as portas à internet. Consulte [o guia do sensor](docs/SENSOR.md).

Antes de contribuir, rode `python3 tools/check_publication.py`. A CI também executa Gitleaks. Essas verificações ajudam a detectar vazamentos, mas não substituem a revisão do conteúdo. Se uma credencial for publicada, revogue-a primeiro: apagar o arquivo não a remove de clones ou do histórico.
