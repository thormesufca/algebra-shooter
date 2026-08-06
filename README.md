# ALGEBRA SHOOTER: Razão e Instinto para Sobrevivência

## 🎯 Conceito
Shooter vertical em que o jogador navega por uma construção antiga sob uma horda de bichos. O desafio está no conflito entre reflexo e raciocínio: powerups flutuam como fragmentos de conhecimento, mas exibem expressões algébricas cujo resultado pode ajudar ou prejudicar.

### Gêneros
* Ação
* Shooter Vertical
* Educacional

---

## ⚙️ Core Loop e Mecânicas
O jogo baseia-se em três mecânicas principais: Cálculo, Risco/Recompensa e Loja/Mercado.

**O ciclo principal (Core Loop) consiste em:**
1. Desviar e atirar
2. Powerup aparece
3. Calcular sob pressão
4. Coletar ou ignorar
5. Economia

---

## 📈 Progressão e Balanceamento

### Desbloqueio de Operadores
A complexidade matemática do jogo evolui em etapas:
* **BASE:** Adição e subtração
* **DESBLOQUEIO 1:** Multiplicação e Divisão
* **DESBLOQUEIO 2:** Potência e raiz

### Balanceamento de Atributos
* Cada atributo possui teto e chão que escalam com a fase, evitando builds desbalanceados.
* As expressões são geradas dentro de uma faixa de resultados controlada, ampliada gradualmente conforme os operadores são desbloqueados e avança-se de fase.

---

## 🛠️ O Que Já Foi Construído (Fase Atual)

### Sistemas
* **Gerador de Powerups:** Objeto responsável por gerar a expressão algébrica de acordo com os parâmetros desbloqueados até o momento (número de dígitos, operadores e limites).
* **Evolução de Atributos:** Os atributos do jogador são incrementados baseado no resultado da expressão algébrica e no multiplicador até o momento. Cada atributo tem sua própria forma de aplicar o incremento, para tornar proporcional ao contexto do jogo.

### Fase Inicial
* Movimento vertical focado na câmera
* Movimento do jogador limitado à câmera
* Geração constante de inimigos
* Fase é configurável para gerar inimigos com base na progressão
