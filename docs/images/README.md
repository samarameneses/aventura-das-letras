# Capturas do jogo

As imagens desta pasta são capturas renderizadas pelo próprio Godot. As três telas de gameplay foram registradas na versão 0.12.0, com um perfil de teste, e copiadas sem edição dos pixels.

| Arquivo | Cena |
| --- | --- |
| `menu.png` | Menu com o elenco selecionável, preservado da captura original |
| `corrida-palavras.png` | Speed Run na fase de palavras, antes de coletar CÉU |
| `acerto-confetes.png` | Salto e coleta real de CÉU, com o efeito de confetes do jogo |
| `palavras-dissilabas.png` | Fase com BOLA e DADO |

## Reproduzir as capturas de gameplay

Depois de importar o projeto no Godot, execute a partir da raiz do repositório, com um ambiente gráfico disponível:

```sh
godot --path game --script res://tests/readme_capture.gd -- --test
```

Use o caminho do seu executável se `godot` não estiver no PATH. A janela do jogo será aberta; o roteiro usa um perfil de teste, executa um salto, verifica a coleta correta e salva as telas em `evidence/readme-*.png`. Não use `--headless`, pois as imagens dependem da renderização gráfica. O comando encerra o jogo ao terminar.

Revise visualmente os resultados antes de atualizar as cópias públicas nesta pasta. Mensagens de incentivo, posições das partículas e tempo do cronômetro podem variar entre execuções.
