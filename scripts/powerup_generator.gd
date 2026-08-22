extends RefCounted

class_name PowerupGenerator

## Operadores de combinação (entre termos) liberados por nível.
const COMBINE_OPERATORS_BY_LEVEL := {
	1: ["+", "-"],
	2: ["+", "-", "*", "/"],
	3: ["+", "-", "*", "/"], ## Nível 3 libera ^ e sqrt() dentro de cada termo (ver _random_term).
}

const MAX_ATTEMPTS := 30 #Quantidade de vezes que vai tentar gerar um valor dentro do range
const RANGE_BASE := 4.0 #Sobrescrito pelo valor da fase
const RANGE_PER_DIGIT := 1.0
const RANGE_PER_OPERATOR := 6.0
const DIGIT_START := 4

#Calcula range de limite com base no que já foi desbloqueado
static func unlock_range(operator_level: int, digit_level: int) -> float:
	return RANGE_BASE \
		+ RANGE_PER_DIGIT * float(digit_level - DIGIT_START) \
		+ RANGE_PER_OPERATOR * float(operator_level - 1)

#Atributos que podem se gerados (removido Shield e Bullet)
const GENERATABLE_ATTRIBUTES := [
	PowerupData.Attribute.DAMAGE,
	PowerupData.Attribute.FIRE_RATE,
	PowerupData.Attribute.MAGNET,
	PowerupData.Attribute.SPEED
]


#Função para gerar o powerup com base nos parâmetros
static func generate(operator_level: int = 1, digit_level: int = 4,	range_min: float = -4.0, range_max: float = 4.0, attribute: int = -1) -> PowerupData:
	var data := PowerupData.new()
	data.operator_level = operator_level
	data.digit_level = digit_level

	#Pega um atributo aleatório entre os geráveis
	if attribute == -1:
		attribute = GENERATABLE_ATTRIBUTES[randi() % GENERATABLE_ATTRIBUTES.size()] 
	data.attribute = attribute as PowerupData.Attribute

	#Cria a expressão algébrica e seu resultado
	var built := _build_expression(operator_level, digit_level, range_min, range_max)
	data.expression = built.display
	data.result = built.value
	return data

#Função para gerar uma expressão algébrica aleatória, com seu resultado (display e value)
static func _build_expression(operator_level: int, digit_level: int, range_min: float, range_max: float) -> Dictionary:
	var fallback := {"display": "1", "value": 1.0}
	#Tenta gerar a expressão, se estiver dentro do range_max, retorna a expressão, senão retorna o fallback ("1" = 1)
	for attempt in range(MAX_ATTEMPTS):
		#Quantidade de termos aleatória, 2 ou 3
		var term_count := 2 if randf() < 0.5 else 3

		#Gera o termo inicial
		var first : Dictionary = _random_term(operator_level, digit_level)
		var display : String = first.display
		var value: float = first.value

		#Gera os demais termos, com operadores entre eles
		for i in range(term_count - 1):
			#Gera um operador
			var op: String = COMBINE_OPERATORS_BY_LEVEL[operator_level][randi() % COMBINE_OPERATORS_BY_LEVEL[operator_level].size()]
			
			#Gera o próximo termo
			var term := _random_term(operator_level, digit_level)
			
			#Aplica o operador aos dois termos anteriores, atualizando o valor resultante
			value = _apply_operator(value, term.value, op)
			
			#Atualiza o display, para colocar os operandos e o operador entre parênteses
			display = "(%s %s %s)" % [display, op, term.display]

		#Se estiver dentro dos limites, retorna o valor calculado e o display, removendo os parênteses externos
		if value >= range_min and value <= range_max:
			return {"display": _strip_outer_parens(display), "value": value}

		#De qualquer forma, seta como fallback a expressão pendente no momento e seu valor, limitado aos ranges
		fallback = {"display": _strip_outer_parens(display), "value": clampf(value, range_min, range_max)}

	return fallback

#Função que sorteia um termo, a depender dos operadores desbloqueados
static func _random_term(operator_level: int, digit_level: int) -> Dictionary:
	#Digito base, random de 1 até o que for desbloqueado
	var base := randi_range(1, digit_level)
	
	#Se potência e raiz estiver desbloqueado, display da expressão é diferente das operações padrão
	if operator_level >= 3:
		#50% de chance de ser raiz ou potência
		var roll := randf()
		if roll < 0.25: #Gerar uma potência
			var exponent := randi_range(2, 3) #Elevado ao quadrado ou ao cubo
			return {"display": "%d^%d" % [base, exponent], "value": pow(base, exponent)} #Retorna base^expoent
		elif roll < 0.5:
			var square := base * base #Se for raiz, para não gerar irracionais, o resultado da raiz será a base
			return {"display": "sqrt(%d)" % square, "value": float(base)}

	return {"display": str(base), "value": float(base)}

static func _apply_operator(a: float, b: float, op: String) -> float:
	match op:
		"+":
			return a + b
		"-":
			return a - b
		"*":
			return a * b
		"/":
			return a / b if b != 0.0 else a
		_:
			return a

# Tira os parênteses externos sempre são adicionados na geração das expressões
static func _strip_outer_parens(expr: String) -> String:
	if expr.begins_with("(") and expr.ends_with(")"):
		return expr.substr(1, expr.length() - 2)
	return expr
	
#Função para descrever o operador (para HUD)
static func describe_operators(operator_level: int) -> String:
	var ops: Array = COMBINE_OPERATORS_BY_LEVEL.get(operator_level, ["+", "-"]).duplicate()
	if operator_level >= 3:
		ops.append_array(["^", "√"])
	return " ".join(ops).replace("*", "×").replace("/", "÷")
