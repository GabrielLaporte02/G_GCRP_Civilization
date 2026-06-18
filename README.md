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
