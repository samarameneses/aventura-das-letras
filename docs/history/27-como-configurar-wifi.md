# Jogar sem fio com a ESP32

## Configurar uma vez

1. Deixe a ESP32 ligada ao Mac pelo cabo USB, com o sensor conectado como no teste.
2. Abra **launchers/macos/Configurar sensor Wi-Fi.command**, na pasta do jogo.
3. Digite o nome da rede doméstica com 2,4 GHz e pressione Enter.
4. Digite a senha e pressione Enter. Por proteção, nenhum caractere aparece enquanto você digita; isso é normal. Não envie a senha no chat.
5. Aguarde a preparação, a gravação e o teste de recebimento. Não retire o cabo nessa etapa.
6. Somente quando aparecer **WI-FI FUNCIONANDO!**, a comunicação pela rede estará confirmada. O jogo abre automaticamente.

O teste exige 100 amostras válidas recebidas pelo Wi-Fi. Enquanto isso, o cabo pode continuar fornecendo energia, mas os dados de movimento chegam pela rede. A calibração dos pulos acontece depois, dentro do jogo, mantendo o sensor parado.

## Usar sem cabo até o computador

Feche o jogo, retire o cabo do Mac e conecte a alimentação USB da ESP32 a um power bank. Use a entrada USB da placa; não ligue uma bateria solta diretamente nos pinos. Mantenha placa e fios firmes, com os contatos protegidos. A troca de alimentação reinicia a placa.

Abra **launchers/macos/Jogar com sensor Wi-Fi.command**. Aguarde o sinal de pronto e clique em **Jogar com sensor**. O personagem corre automaticamente. O Mac precisa continuar ligado e conectado à mesma rede local. Não é necessário publicar o jogo nem abrir portas no roteador.

Se o power bank desligar sozinho, ele pode estar interrompendo a saída com consumo baixo; nesse caso, será necessário usar uma alimentação que mantenha a saída USB ativa para esse dispositivo.

## Se não conectar

Confira nome e senha, proximidade do roteador e disponibilidade de 2,4 GHz. Uma rede de convidados pode impedir a comunicação entre dispositivos. O Mac pode estar em outra faixa de frequência do mesmo roteador, desde que ambos pertençam à mesma rede local e consigam se comunicar.

Se o teste após gravar não receber dados suficientes, o configurador tenta restaurar o firmware USB previamente verificado e informa o resultado. Não trate a tentativa como sucesso se aparecer erro.

Se o endereço local do Mac mudar, o atalho avisa e pede para repetir a configuração com a ESP32 conectada por USB. Não é necessário redigitar a configuração a cada partida quando o endereço permanece o mesmo.

## Estado verificado em 12/09/2026

O firmware Wi-Fi foi compilado e gravado na ESP32 com a rede fornecida pelo usuário. O teste físico recebeu 100 amostras válidas pela rede; o jogo abriu no modo sensor com corrida automática e o receptor confirmou a calibração. Evidência: `evidence/esp32-wifi-setup.json`.

Durante esse teste, a placa continuou alimentada pelo USB do Mac. A comunicação Wi-Fi está confirmada; o funcionamento com alimentação por power bank ainda precisa ser testado. O perfil USB original do projeto e a imagem de recuperação foram preservados. Arquivos com credenciais, binários e registros detalhados ficam nas pastas locais ignoradas pelo Git. A senha não é registrada nesta documentação.

Referências: [Wi-Fi Arduino ESP32](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/wifi.html) e [datasheet do ESP32 clássico, rádio 2,4 GHz](https://documentation.espressif.com/esp32_datasheet_en.html).

## Correção de pulos intermitentes no power bank — 12/09/2026

Após a troca de alimentação informada pelo usuário, o receptor continuou recebendo dados, mas um registro de 12.191 amostras mostrou oito intervalos de chegada acima de 150 ms, com máximo de 716 ms. O código anterior descartava a calibração após pausas de 150–300 ms. Dados recebidos em blocos também distorciam a duração do movimento, pois o detector usava o horário de chegada ao Mac.

O detector agora mede os movimentos pelo relógio de aquisição da ESP32. Pausas curtas cancelam um gesto incompleto, mas preservam uma calibração já concluída. A calibração inicial ainda exige continuidade e imobilidade. Receptor e jogo consideram desconexão após 1,2 segundo sem dados válidos; amostras antigas continuam sendo rejeitadas e não há envio artificial de sinais de conexão.

Validação: 19 testes Python passaram, incluindo os casos que falhavam com pausas e dados agrupados. O teste Godot confirma tolerância de 900 ms e desconexão em 1.300 ms. Repetir o registro físico com o detector corrigido reduziu as calibrações de seis para uma e reconheceu sete pulos; isso é uma reprodução do registro, não uma confirmação de sete pulos executados ao vivo. Evidências: `evidence/wifi-powerbank-replay.json` e `evidence/sensor-wifi-timeout.json`. O teste de jogabilidade ao vivo após a correção ainda precisa de confirmação do usuário.
