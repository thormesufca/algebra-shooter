@tool
extends RichTextEffect
class_name RichTextRaise
## Tag BBCode customizada que desloca o texto verticalmente.
## Combinada com a tag nativa [font_size], simula um sobrescrito visual real
## (texto menor + elevado), já que o Godot não possui uma tag [sup] nativa
## e os efeitos customizados não conseguem alterar o tamanho da fonte por
## caractere — apenas a posição.
##
## Sintaxe: [raise amount=8.0]texto[/raise]
##   amount: deslocamento vertical em pixels (positivo = sobe o texto)
##
## IMPORTANTE: para a tag funcionar, este efeito precisa estar registrado
## no RichTextLabel — via Inspector (Markup > Custom Effects) ou via código
## com richtextlabel.install_effect(RichTextRaise.new()) ANTES de definir
## a propriedade `text`.

var bbcode := "raise"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var amount: float = char_fx.env.get("amount", 8.0)
	char_fx.offset.y -= amount
	return true
