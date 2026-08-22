extends Area2D

#Projétil de pedra do minotauro.

@export var speed: float = 260.0
@export var lifetime: float = 6.0
var direction: Vector2 = Vector2.DOWN

var _age: float = 0.0
var _has_hit: bool = false

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation = direction.angle()
	_age += delta
	if _age > lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _has_hit or not body.is_in_group("player"):
		return
	_has_hit = true
	body.take_damage_from(global_position)
	queue_free()
