# Meownarch

Projeto desenvolvido na disciplina **Tendências, Mídia & Interação (2026.1)** utilizando **Godot 4.7**.

**Meownarch** é um jogo experimental que explora a interação entre o jogador e agentes de IA com diferentes perfis comportamentais, utilizando respostas geradas em tempo real durante a execução do jogo.

## Conceito

A proposta de **Meownarch** é colocar o jogador ao lado de um gato que o auxilia a comandar um grupo de dinossauros com comportamentos distintos. Cada dinossauro possui uma personalidade própria, influenciando suas decisões e respostas às ações dos outros dinossauros.

Devido ao escopo e ao tempo de desenvolvimento do projeto, essa ideia não pôde ser implementada integralmente. Mas, o jogo apresenta o conceito base do sistema de personalidades e da interação com IAs proposto.

## Funcionalidades

* Quatro personalidades distintas de IA:

  * Cooperativa
  * Egoísta
  * Agressiva
  * Estratégica
* Geração de respostas em tempo real utilizando a API do Replicate com o modelo **GPT-4.1 Mini**.
* Histórico de conversa para manter o contexto entre jogador e IA.

## Tecnologias

* Godot 4.7
* GDScript
* Replicate API
* GPT-4.1 Mini (`openai/gpt-4.1-mini`)

## Como executar

### Pré-requisitos

* Godot 4.7
* Token de acesso da API do Replicate.

### Instalação

1. Clone este repositório.
2. Abra o projeto utilizando o Godot 4.7.
3. Localize o script `API_Communication.gd`.
4. Configure seu token na variável:

```gdscript
var token = "SEU_TOKEN_AQUI"
```

5. Execute o projeto pelo editor do Godot.

## Estrutura das IAs

Cada agente utiliza um *System Prompt* para definir seu comportamento. As mensagens enviadas pelo jogador e as respostas da IA são armazenadas temporariamente para preservar o contexto da conversa durante a partida.

## Autores

Projeto desenvolvido por:

* Gabriel Montenegro
* Caio Ferreira
* Renatto Padilha
* Pedro Dantas

Como parte da disciplina **Tendências, Mídia & Interação – 2026.1**.
