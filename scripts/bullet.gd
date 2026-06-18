extends Area2D

@export var speed: float = 800.0
@export var bullet_size: float = 1.0

signal enemy_hit

func _physics_process(delta: float) -> void:
	position.y -= speed * delta
	if position.y < -20:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.queue_free()
		queue_free()
		enemy_hit.emit()
		#var player = get_tree().get_first_node_in_group("player")
		#if player:
			#player.bullet_amount += 1
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(bullet_size, bullet_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
