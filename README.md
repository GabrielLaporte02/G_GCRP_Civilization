# 🌍 Simulador de Civilização (Godot 4)

Este projeto é um simulador "sandbox" baseado em turnos onde entidades autônomas sobrevivem e competem por recursos. O objetivo é observar comportamentos emergentes baseados na teoria dos jogos e na interação em um ambiente fechado.

**Os Agentes** foram programados como estruturas puras de dados. Cada agente é instanciado com atributos biológicos (Vida, Fome) e uma **Personalidade** base de fábrica ("Agressivo" ou "Cooperativo"). Eles não possuem controle manual; suas decisões de movimentação e combate são tomadas automaticamente pelas suas próprias lógicas internas baseadas nessa personalidade, enquanto um orquestrador mestre processa as consequências desses encontros ao fim de cada turno.

---

## 🧠 Detalhes Técnicos e Módulos

A simulação roda sobre uma mecânica de turnos em um grid de 10x10. A lógica em GDScript foi dividida de maneira modular:

### 1. Entidade Agente (`Agente.gd`)
Um script de dados (Resource) puro, que define as propriedades e comportamentos básicos de cada entidade no mundo.
- **Atributos:** Possuem Vida, Visão, Força de Combate, e recursos (Comida, Madeira, Pedra).
- **Personalidades:** 
  - **"Agressivo":** Sempre optará por atacar outros agentes que encontrar.
  - **"Cooperativo":** Sempre tentará cooperar.
- **Morte por Fome:** Agentes perdem 1 de comida por turno; caso não possuam comida, perdem 1 de vida.

### 2. O Gerenciador de Turnos (`Gerenciador.gd`)
O "motor" (orquestrador) do jogo. Ele controla o loop principal:
1. **Movimento:** No início do turno, cada agente move-se aleatoriamente (-1 a +1) nos eixos X e Y pelo grid.
2. **Sobrevivência:** Resolve o decréscimo de comida e checa quem sobrevive. Agentes com vida zerada são removidos da simulação.
3. **Interação:** Verifica se dois agentes terminaram o turno no mesmo bloco espacial (mesmo x e y) e invoca um conflito.

### 3. Sistema de Conflitos
Quando dois agentes se encontram no mesmo espaço:
- **Cooperar vs Cooperar:** Paz, nada acontece.
- **Atacar vs Cooperar (ou vice-versa):** O agressor vence a batalha automaticamente.
- **Atacar vs Atacar:** O agente com maior valor de `combate` vence. Em caso de empate, ambos perdem 1 ponto de vida e o combate acaba.
> *O Vencedor de um conflito "rouba" todo o estoque de comida, madeira e pedra do perdedor e reduz a vida do perdedor em 1.*

### 4. Interface e Log (`UI.gd` e `GridVisual.gd`)
Para que possamos ver os dados acontecendo, a cena `Main.tscn` conta com:
- **Painel de Log (Direita):** Registra cada passo em texto (movimentação, combates, perdas de vida e mortes).
- **Grid de Visão (Esquerda):** Um representador visual simples que processa a matriz e mostra quadrados que viajam pela tela.
  - **Quadrados Vermelhos:** Agentes Agressivos.
  - **Quadrados Azuis:** Agentes Cooperativos.

## 🚀 Como Executar o Projeto

Como o jogo foi construído na **Godot Engine**, siga estes passos para testar a simulação:

1. **Baixe o Godot 4:** 
    baixe pela Steam. Baixe a versão Godot 4.x "Standard" (não é necessário a versão .NET para este projeto). O programa não precisa ser instalado, basta descompactar e abrir o executável.

2. **Importando no Godot:**
   - Abra o Godot Engine.
   - Na janela inicial, clique em **"Import"** (Importar).
   - Clique em **"Browse"** (Navegar) e localize a pasta `game` deste repositório que contém o arquivo `project.godot`.
   - Selecione o arquivo e clique em **"Import & Edit"** (Importar & Editar).

3. **Rodando a Simulação:**
   - Com o editor aberto, pressione a tecla **F5** no teclado (ou aperte o botão "Play Project" no canto superior direito do editor).
   - A janela de jogo abrirá.
   - **Controles:**
     - Clique em **"Próximo Turno"** com o mouse para avançar a simulação passo a passo.
     - Pressione **'R'** no teclado para reinicializar todos os agentes imediatamente a qualquer momento.

## 📁 Project Structure

A estrutura do projeto está organizada em pastas separadas para o projeto Godot principal, a versão de teste e os arquivos de suporte do simulador:

```text
G_GCRP_CivilizationTest01/
├── README.md
├── g-gcrp-civilization/
│   ├── project.godot
│   ├── World.tscn
│   ├── _dev/
│   │   └── DevTileReference.tscn
│   ├── assets/
│   │   └── tiles/
│   │       ├── main_tileset.tres
│   │       └── imagens e imports de tiles
│   └── core/
│       ├── data/
│       ├── events/
│       └── world_generation/
├── game/
│   ├── Agente.gd
│   ├── Gerenciador.gd
│   ├── GridVisual.gd
│   ├── UI.gd
│   ├── Main.tscn
│   ├── main.py
│   └── project.godot
├── simulador-de-civilizacao-(4.2)/
│   ├── Agente.gd
│   ├── Gerenciador.gd
│   ├── GridVisual.gd
│   ├── UI.gd
│   ├── Main.tscn
│   ├── main.py
│   └── project.godot
└── simulador-de-civilizacao-(4.6)/
    ├── Agente.gd
    ├── Gerenciador.gd
    ├── GridVisual.gd
    ├── UI.gd
    ├── Main.tscn
    ├── main.py
    ├── project.godot
    └── .gd and .uid support files
```

Esta seção serve apenas para documentar a organização atual dos arquivos e pastas, sem alterar a estrutura do projeto.

## 🧭 Sumário do Projeto

Abaixo está um resumo objetivo de cada pasta e arquivo principal, mostrando o que cada parte é responsável e como ela participa no funcionamento do projeto.

### Pastas e arquivos principais

- `README.md`
  - Arquivo de documentação geral do projeto.
  - Explica o objetivo do simulador, como executar e como a estrutura foi organizada.

- `g-gcrp-civilization/`
  - Pasta principal do projeto Godot com a versão mais organizada e modular do simulador.
  - Contém os arquivos de configuração do projeto, cenas e scripts de lógica do mundo.

- `g-gcrp-civilization/project.godot`
  - Arquivo central do projeto Godot.
  - Define a configuração principal do projeto e o ponto de entrada do engine.

- `g-gcrp-civilization/World.tscn`
  - Cena principal do mundo do simulador.
  - Organiza os elementos visuais e os nós que compõem a cena do jogo.

- `g-gcrp-civilization/_dev/`
  - Pasta para arquivos auxiliares de desenvolvimento.
  - Pode guardar referências, protótipos ou cenas de apoio usadas durante a criação.

- `g-gcrp-civilization/assets/tiles/`
  - Pasta de recursos visuais do projeto.
  - Armazena os tiles, imagens e arquivos de configuração de aparência do mapa.

- `g-gcrp-civilization/core/data/`
  - Responsável por armazenar as estruturas de dados do simulador.
  - Aqui ficam as definições das entidades, atributos e dados usados pelo jogo.

- `g-gcrp-civilization/core/events/`
  - Contém a lógica de comunicação entre módulos.
  - Serve para transmitir eventos e ações entre diferentes partes do sistema.

- `g-gcrp-civilization/core/world_generation/`
  - Responsável por gerar o ambiente do mundo simulado.
  - Controla a criação do mapa, configuração do cenário e renderização visual do mundo.

- `game/`
  - Pasta com uma versão do simulador em uma estrutura mais direta e simples.
  - É uma implementação prática para execução e visualização da simulação.

- `game/Agente.gd`
  - Define o comportamento e os atributos básicos dos agentes.
  - Representa a entidade que vive, se move e interage no mundo.

- `game/Gerenciador.gd`
  - É o núcleo da simulação.
  - Controla o fluxo de turnos, decisões e regras do jogo.

- `game/GridVisual.gd`
  - Responsável pela parte visual do grid.
  - Mostra o estado do ambiente e a posição dos agentes na tela.

- `game/UI.gd`
  - Gerencia a interface do usuário.
  - Controla os elementos visuais e a interação com o jogador.

- `game/Main.tscn`
  - Cena principal da interface do projeto.
  - Junta os componentes visuais e os scripts do simulador.

- `game/main.py`
  - Arquivo de apoio ou execução alternativa do simulador.
  - Pode ser usado para testes, integração ou execução fora do ambiente Godot.

- `simulador-de-civilizacao-(4.2)/`
  - Pasta com uma versão antiga ou intermediária do projeto.
  - Mantém uma implementação semelhante do simulador para referência ou comparação.

- `simulador-de-civilizacao-(4.6)/`
  - Pasta com uma versão mais recente ou experimental do projeto.
  - Serve como outra implementação do simulador, com arquivos compatíveis com a estrutura atual.

### Como as partes se conectam

- Os arquivos `Agente.gd`, `Gerenciador.gd` e `UI.gd` trabalham juntos para formar a lógica principal do simulador.
- O arquivo `Main.tscn` organiza a cena e conecta os scripts à interface.
- A pasta `core` no projeto Godot separa melhor as responsabilidades, deixando o código mais modular.
- As pastas `assets` e `_dev` ajudam na parte visual e no suporte durante o desenvolvimento.