extends CharacterBody2D

class_name Enemy

signal died(death_position: Vector2)
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@export var max_health: int = 5

var player: Player = null
var speed: float = 100.0
var direction := Vector2.ZERO



var health:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	progress_bar.max_value = max_health
	progress_bar.value = max_health
	player = get_tree().get_nodes_in_group("player")[0] as Player

func _physics_process(delta: float) -> void:
	print("Entrei")
	if player != null:
		var enemy_to_player = (player.global_position - global_position)
		direction = enemy_to_player.normalized()
		if direction != Vector2.ZERO:
			velocity = speed * direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)

		move_and_slide()
	
func _process(delta: float) -> void:
	look_at(player.global_position)

func take_damage(amount: int)->void:
	health -= amount
	progress_bar.value = health
	if health <= 0:
		die()

func die()->void:
	died.emit(global_position)
	queue_free()
