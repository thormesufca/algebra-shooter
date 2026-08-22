extends Area2D

@export var speed: float = 260.0
@export var lifetime: float = 6.0 #Tempo de duração da clava

@export var homing: bool = false #Caso a clava siga o jogador
var target: Node2D = null
var direction: Vector2 = Vector2.DOWN

var _age: float = 0.0
var _has_hit: bool = false

func _physics_process(delta: float) -> void:
	if homing and target != null and is_instance_valid(target): #Calcula direção do jogador apenas se precisar seguir
		direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	_age += delta
	if _age > lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _has_hit or not body.is_in_group("player"):
		return
	_has_hit = true
	body.take_damage_from(global_position)
	queue_free()
