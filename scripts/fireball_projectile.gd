extends Area2D

@export var speed: float = 220.0 #Velocidade
@export var lifetime: float = 6.0 #Tempo de vida
@export var grows: bool = false #Se é para cresce
@export var growth_rate: float = 0.8 #Velocidade de crescimento
@export var max_scale: float = 6 #Escala máxima
var direction: Vector2 = Vector2.DOWN

var _age: float = 0.0
var _has_hit: bool = false

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation = direction.angle()
	if grows and scale.x < max_scale:
		var new_scale: float = min(scale.x + growth_rate * delta, max_scale)
		scale = Vector2(new_scale, new_scale)
	_age += delta
	if _age > lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _has_hit or not body.is_in_group("player"):
		return
	_has_hit = true
	body.take_damage_from(global_position)
	queue_free()
