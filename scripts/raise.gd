@tool
extends RichTextEffect
class_name RichTextRaise
#Tag criada para permitir uso de formatação especial em RichText, para mostrar potência no powerup
var bbcode := "raise"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var amount: float = char_fx.env.get("amount", 8.0)
	char_fx.offset.y -= amount #Mostra caracter um pouco acima
	return true
