# Algebra Shooter

Projeto desenvolvido para a disciplina de Introdução ao Design de Jogos na Universidade Federal do Cariri (UFCA). O game mistura ação arcade, progressão e raciocínio matemático em uma experiência de shooter vertical com estética de masmorra antiga e tema de sobrevivência.

## 🎯 Conceito
Algebra Shooter é um jogo em que o jogador navega por uma construção antiga enquanto enfrenta uma horda de inimigos. O desafio não está apenas em reagir rápido, mas também em decidir se vale a pena aceitar ou ignorar powerups que trazem expressões algébricas com resultados positivos ou negativos para os atributos do personagem.

### Gêneros
- Ação
- Shooter vertical
- Educacional

---

## 🕹️ Como funciona
O gameplay é baseado em um ciclo principal de sobrevivência e decisão:

1. Desviar dos inimigos e atirar com precisão.
2. Derrotar inimigos para gerar powerups.
3. Interpretar expressões algébricas sob pressão.
4. Coletar ou ignorar o powerup com base no risco/recompensa.
5. Melhorar o personagem e enfrentar fases cada vez mais desafiadoras.

---

## ⚙️ Mecânicas principais

### Combate e sobrevivência
- O jogador se move em duas dimensões e atira em direção ao cursor do mouse.
- Inimigos aparecem continuamente e podem causar dano ao personagem.
- O personagem possui escudo, invulnerabilidade temporária após ser atingido e knockback ao sofrer impacto.

### Powerups algébricos
- Ao derrotar certos inimigos, surgem powerups flutuantes na tela.
- Cada powerup exibe uma expressão matemática e um resultado.
- O resultado influencia atributos do jogador, como:
  - dano
  - cadência de tiro
  - escudo
  - magnetismo
  - quantidade de projéteis
  - velocidade

### Progressão e dificuldade
- O jogo possui fases com configurações próprias de spawn, câmera e inimigos.
- A dificuldade pode aumentar conforme a câmera percorre a fase.
- O sistema de powerups também introduz um elemento de risco/recompensa (cashout), já que ignorar um item pode aumentar um multiplicador para as próximas decisões.

---

## 🎮 Controles
- Movimentação: WASD ou setas direcionais
- Mira e tiro: mouse
- Pausar: tecla P

---

## 🧱 Estrutura do projeto
A estrutura do projeto está organizada em pastas principais:

- assets/: imagens, fontes, sons e sprites utilizados no jogo
- entities/: cenas de entidades como jogador, inimigos, projéteis e powerups
- resources/: recursos reutilizáveis como dados de fases e ícones
- scenes/: cenas principais da interface e da gameplay loop
- scripts/: lógica do jogo em GDScript, incluindo combate, geração de powerups, fases e HUD
- themes/: temas visuais da interface

---

## ▶️ Como executar
1. Abra o projeto no Godot Engine 4.x.
2. Carregue o arquivo project.godot.
3. Execute a cena principal para iniciar o jogo.

> Recomendação: utilizar a versão 4.7 ou superior, conforme indicado no projeto.

---

## 📌 Observação
O projeto ainda está em evolução, mas já apresenta uma proposta clara de jogo que une ação arcade, progressão e aprendizado matemático em um mesmo loop de gameplay.
