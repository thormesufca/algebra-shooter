extends RefCounted

class_name PowerupGenerator

## Operadores de combinação (entre termos) liberados por nível.
## Nível 3 também libera ^ e sqrt() dentro de cada termo (ver _random_term).
const COMBINE_OPERATORS_BY_LEVEL := {
	1: ["+", "-"],
	2: ["+", "-", "*", "/"],
	3: ["+", "-", "*", "/"],
}

const MAX_ATTEMPTS := 30

## Atributos sorteáveis. SPEED fica de fora até ter ícone/animação próprios.
const GENERATABLE_ATTRIBUTES := [
	PowerupData.Attribute.DAMAGE,
	PowerupData.Attribute.FIRE_RATE,
	PowerupData.Attribute.SHIELD,
	PowerupData.Attribute.MAGNET,
	PowerupData.Attribute.BULLET_AMOUNT,
]

## Gera um PowerupData com expressão/resultado dentro de [range_min, range_max],
## respeitando os operadores e dígitos desbloqueados no momento da chamada.
static func generate(
	operator_level: int = 1,
	digit_level: int = 4,
	range_min: float = -4.0,
	range_max: float = 4.0,
	attribute: int = -1
) -> PowerupData:
	var data := PowerupData.new()
	data.operator_level = operator_level
	data.digit_level = digit_level

	if attribute == -1:
		attribute = GENERATABLE_ATTRIBUTES[randi() % GENERATABLE_ATTRIBUTES.size()]
	data.attribute = attribute

	var built := _build_expression(operator_level, digit_level, range_min, range_max)
	data.expression = built.display
	data.result = built.value
	return data

static func _build_expression(operator_level: int, digit_level: int, range_min: float, range_max: float) -> Dictionary:
	var fallback := {"display": "1", "value": 1.0}
	for attempt in range(MAX_ATTEMPTS):
		var term_count := 2 if randf() < 0.5 else 3
		var first : Dictionary = _random_term(operator_level, digit_level)
		var display : String = first.display
		var value: float = first.value

		for i in range(term_count - 1):
			var op: String = COMBINE_OPERATORS_BY_LEVEL[operator_level][randi() % COMBINE_OPERATORS_BY_LEVEL[operator_level].size()]
			var term := _random_term(operator_level, digit_level)
			value = _apply_operator(value, term.value, op)
			display = "(%s %s %s)" % [display, op, term.display]

		if value >= range_min and value <= range_max:
			return {"display": _strip_outer_parens(display), "value": value}
		fallback = {"display": _strip_outer_parens(display), "value": clampf(value, range_min, range_max)}

	return fallback

## Um termo isolado: um dígito simples, ou (a partir do nível 3) uma potência
## ou raiz quadrada de um dígito, no mesmo formato aceito por ExprToBBCode.
static func _random_term(operator_level: int, digit_level: int) -> Dictionary:
	var base := randi_range(1, digit_level)

	if operator_level >= 3:
		var roll := randf()
		if roll < 0.25:
			var exponent := randi_range(2, 3)
			return {"display": "%d^%d" % [base, exponent], "value": pow(base, exponent)}
		elif roll < 0.5:
			var square := base * base
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

## Tira os parênteses externos que sobram quando só há um termo (ex: "(5)" -> "5").
static func _strip_outer_parens(expr: String) -> String:
	if expr.begins_with("(") and expr.ends_with(")"):
		return expr.substr(1, expr.length() - 2)
	return expr
