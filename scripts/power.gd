extends Area2D

@export var expression: String = "5 - 4"
@export var fall_speed: float = 120.0       # velocidade de queda/avanço
@export var amplitude: float = 30.0         # amplitude do zigue-zague
@export var frequency: float = 2.0          # frequência da oscilação
@export var move_direction: Vector2 = Vector2.DOWN  # direção principal do movimento


@onready var label: RichTextLabel = $ExpressionLabel

var _time: float = 0.0
var _perpendicular: Vector2
var _origin: Vector2

const ExprToBBCode := preload("res://scripts/ExprToBBCode.gd")
const RichTextRaiseEffect := preload("res://scripts/raise.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.bbcode_enabled = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.fit_content = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.install_effect(RichTextRaiseEffect.new())
	label.text = ExprToBBCode.expr_to_bbcode(expression)
 
	#_origin = global_position
	#_perpendicular = move_direction.orthogonal().normalized()
 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#_time += delta
 
	# avança na direção principal + oscila na direção perpendicular
	#var forward := move_direction.normalized() * fall_speed * _time
	#var sway := _perpendicular * sin(_time * frequency) * amplitude
	#global_position = _origin + forward + sway
 
	# opcional: remover quando saí da tela (ajuste ao tamanho da sua viewport)
	#var viewport_size := get_viewport_rect().size
	#if global_position.y > viewport_size.y + 64:
	#	queue_free()
		
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_apply_powerup_effect(body)
		queue_free()
		
func _apply_powerup_effect(player: Node) -> void:
	# implemente aqui o efeito do powerup associado à expressão
	player.damage += 1
	print("Novo Damage: ", player.damage)
