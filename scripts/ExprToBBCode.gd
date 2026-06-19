extends Node
## Converte uma expressão algébrica em texto simples (com ^ e sqrt())
## para uma string BBCode pronta para um RichTextLabel.
##
## IMPORTANTE SOBRE EXPOENTES:
## O BBCode do Godot NÃO possui uma tag [sup] nativa, e efeitos customizados
## (RichTextEffect) não conseguem alterar o tamanho da fonte por caractere
## — apenas a posição. Por isso, o sobrescrito aqui é simulado combinando
## a tag nativa [font_size] (encolhe o texto) com uma tag customizada
## [raise] (eleva o texto), definida em rich_text_raise.gd.
##
## PRÉ-REQUISITO: o efeito RichTextRaise precisa estar registrado no
## RichTextLabel antes de definir `text`. Veja powerup.gd para um exemplo
## (label.install_effect(RichTextRaise.new())).
##
## Sintaxe de entrada esperada:
##   +  -  *  /      -> operações básicas (* e / são trocados por × e ÷)
##   base^expoente    -> expoente: número simples, ou subexpressão entre
##                       parênteses (ambos viram sobrescrito real).
##   sqrt(expressao)  -> raiz quadrada
##
## Exemplos de entrada válidos:
##   "2^3 + sqrt(16) - 5*2/4"
##   "2^(3+1)"
##   "2^(3*2)"   <- agora funciona corretamente, diferente da versão anterior
##                  baseada em caracteres Unicode (que não cobria * e /).


## Tamanho de fonte do sobrescrito e deslocamento vertical, em pixels.
## Ajuste esses valores de acordo com o tamanho de fonte base do seu
## RichTextLabel (ex: se a base for 24px, um sobrescrito de 14px com
## raise de 8px costuma ficar proporcional).
const SUP_FONT_SIZE := 14
const SUP_RAISE := 8.0


static func _wrap_superscript(text: String) -> String:
	return "[font_size=%d][raise amount=%.1f]%s[/raise][/font_size]" % [
		SUP_FONT_SIZE, SUP_RAISE, text
	]


static func expr_to_bbcode(expr: String) -> String:
	var result := ""
	var i := 0
	var n := expr.length()

	while i < n:
		var c := expr[i]

		# --- sqrt( ... ) ---
		if expr.substr(i, 5) == "sqrt(":
			var open_idx := i + 4
			var close_idx := _find_matching_paren(expr, open_idx)
			if close_idx == -1:
				result += expr.substr(i)
				break
			var inner := expr.substr(open_idx + 1, close_idx - open_idx - 1)
			result += "√(" + expr_to_bbcode(inner) + ")"
			i = close_idx + 1
			continue

		# --- expoente: base^exp ---
		if c == "^":
			i += 1
			if i < n and expr[i] == "(":
				# expoente entre parênteses: converte recursivamente
				# (trata ^ e sqrt aninhados) e eleva o resultado por completo,
				# incluindo os parênteses normais (o [font_size] já cuida do
				# tamanho, não precisamos de parênteses Unicode).
				var close_idx2 := _find_matching_paren(expr, i)
				if close_idx2 == -1:
					result += "^" + expr.substr(i)
					break
				var exp_inner := expr.substr(i + 1, close_idx2 - i - 1)
				var inner_converted := expr_to_bbcode(exp_inner)
				result += _wrap_superscript("(" + inner_converted + ")")
				i = close_idx2 + 1
			else:
				# expoente numérico simples (com sinal opcional)
				var j := i
				if j < n and (expr[j] == "-" or expr[j] == "+"):
					j += 1
				while j < n and expr[j].is_valid_int():
					j += 1
				var exp_token := expr.substr(i, j - i)
				result += _wrap_superscript(exp_token)
				i = j
			continue

		# --- símbolos de multiplicação e divisão ---
		if c == "*":
			result += "×"
			i += 1
			continue
		if c == "/":
			result += "÷"
			i += 1
			continue

		# --- qualquer outro caractere (números, +, -, parênteses, espaços) ---
		result += c
		i += 1

	return result


## Encontra o índice de fechamento do parêntese que abre em open_index.
## Retorna -1 se não encontrar (parênteses desbalanceados).
static func _find_matching_paren(expr: String, open_index: int) -> int:
	var depth := 0
	for i in range(open_index, expr.length()):
		if expr[i] == "(":
			depth += 1
		elif expr[i] == ")":
			depth -= 1
			if depth == 0:
				return i
	return -1
