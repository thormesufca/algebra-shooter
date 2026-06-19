extends Area2D

@export var speed: float = 800.0
@export var bullet_size: float = 1.0
@export var damage: float = 1.0
var direction: Vector2 = Vector2.UP
@export var lifetime: float = 2.0
var _age: float = 0.0



signal enemy_hit

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	if _age > lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		#area.queue_free()
		area.take_damage(damage)
		enemy_hit.emit()
		queue_free()
		#var player = get_tree().get_first_node_in_group("player")
		#if player:
			#player.bullet_amount += 1
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(bullet_size, bullet_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
