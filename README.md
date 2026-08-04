# Capitão Dentada

**Capitão Dentada** é um jogo desenvolvido como trabalho para a disciplina de **Projeto de Jogos**, combinando duas formas diferentes de jogabilidade: fases de plataforma em **2D** e travessias navais em **3D**.

O projeto apresenta a aventura do Capitão Dentada, um pirata que teve seu navio, seu ouro e sua tripulação roubados pelo Almirante Cedro. Para recuperar seus bens e companheiros, o capitão precisa atravessar diferentes ilhas, enfrentar criaturas e participar de combates navais.

## Estado atual

A versão atual representa um **MVP — Produto Mínimo Viável** do jogo.

O objetivo desta versão é demonstrar:

- a integração entre fases 2D e 3D;
- a progressão entre travessias e ilhas;
- a movimentação dos personagens e embarcações;
- o sistema de combate terrestre e naval;
- as interfaces de instrução, vida, derrota e vitória;
- a batalha final contra o Almirante Cedro.

Por se tratar de um MVP desenvolvido dentro do período da disciplina, o jogo ainda possui bastante espaço para melhorias, ajustes de balanceamento, expansão de conteúdo e refinamento técnico e visual.

## Estrutura do jogo

O jogo alterna entre travessias navais em 3D e fases de plataforma em 2D.

A progressão atual ocorre na seguinte ordem:

1. **Travessia 01 — 3D**
   - Introdução à navegação.
   - Travessia realizada com um bote.
   - Não possui combate naval.

2. **Fase 01 — 2D**
   - Primeira fase de plataforma.
   - Exploração da ilha e combate contra inimigos.

3. **Travessia 02 — 3D**
   - Navegação com um navio maior.
   - Introdução ao combate naval.
   - Enfrentamento de embarcações inimigas.

4. **Fase 02 — 2D**
   - Segunda fase de plataforma.
   - Novos desafios e inimigos.
   - Batalha em terra final contra o Almirante Cedro.

5. **Travessia 03 — 3D**
   - Batalha naval final.
   - Confronto contra o navio do Almirante Cedro.
   - Exibição da tela de vitória após a derrota do chefe.

## Controles

### Fases 2D

| Ação | Tecla |
|---|---|
| Mover para a esquerda | `A` ou `Seta para a esquerda` |
| Mover para a direita | `D` ou `Seta para a direita` |
| Pular | `Espaço` |
| Atacar | `Q` ou `Botão esquerdo do mouse` |

### Travessias 3D

| Ação | Tecla |
|---|---|
| Avante | `W` ou `Seta para cima` |
| Recuar | `S` ou `Seta para baixo` |
| Virar para bombordo | `A` ou `Seta para a esquerda` |
| Virar para boreste | `D` ou `Seta para a direita` |
| Disparar bomba | `Espaço` |

## Principais funcionalidades implementadas

- Movimentação e combate em fases de plataforma 2D.
- Navegação com bote e navios em ambiente 3D.
- Sistema de disparo de bombas.
- Inteligência básica para navios inimigos.
- Sistema de vida do jogador e dos inimigos.
- Barra de vida exclusiva para o chefe final.
- Animação introdutória de câmera.
- Animação de balanço dos navios e das velas.
- Áreas invisíveis delimitando o espaço navegável.
- Portos que realizam a transição entre as travessias 3D e as fases 2D.
- Tela de instruções antes do início de cada travessia.
- Tela de Game Over com opção de reiniciar.
- Tela de vitória com opções para rejogar a batalha final ou voltar ao início.

## Tecnologias utilizadas

- **Godot Engine 4**
- **GDScript**
- Cenas e mecânicas em **2D**
- Cenas e mecânicas em **3D**
- Git e GitHub para versionamento e desenvolvimento colaborativo

## Execução do projeto via Godot

1. Abra o projeto na Godot Engine.
2. Aguarde a importação dos recursos.
3. Confirme que a cena principal do projeto está configurada corretamente.
4. Execute o jogo utilizando `F6` para a cena atual ou `F5` para o projeto completo.

## Execução via .exe (Windows)

O projeto acompanha um executável do jogo:

    CapitaoDentada.exe

## Possíveis melhorias futuras

Entre as melhorias planejadas ou possíveis estão:

- inclusão de novas fases 2D;
- criação de novas travessias;
- maior variedade de inimigos;
- novos padrões de ataque para o Almirante Cedro;
- melhoria da inteligência artificial dos navios;
- efeitos visuais para impactos e destruição;
- efeitos sonoros e música;
- diálogos e cenas narrativas;
- sistema de salvamento e progressão;
- tela de menu principal;
- configurações de áudio e controles;
- melhor balanceamento da vida e do dano;
- refinamento das colisões;
- melhoria das animações;
- otimização do desempenho;
- polimento geral da interface;
- testes com jogadores e ajustes de usabilidade.

## Recursos visuais

O projeto utiliza recursos visuais disponibilizados por diferentes pacotes de assets, incluindo:

- Pixel Frog — Treasure Hunters;
- Pixel Frog — Pirate Bomb;
- Kenney — Pirate Kit 3D;
- recursos adicionais de interface, fontes e elementos gráficos.

Os respectivos direitos sobre os recursos pertencem aos seus criadores, de acordo com as licenças fornecidas em cada pacote.

## Observação acadêmica

Este projeto foi produzido para fins acadêmicos, como parte das atividades da disciplina de **Projeto de Jogos**.

A versão apresentada não representa necessariamente o estado final idealizado para o jogo. Ela foi construída para validar a proposta principal, demonstrar a integração entre os estilos 2D e 3D e disponibilizar uma experiência jogável do início ao confronto final.