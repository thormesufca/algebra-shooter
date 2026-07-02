extends CharacterBody2D

class_name Enemy

signal died(death_position: Vector2)
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@export var max_health: int = 5
@export var coin_scene: PackedScene
@export var reward_value: int = 1

var player: Player = null
var speed: float = 100.0
var direction := Vector2.ZERO

const KNOCKBACK_FRICTION := 600.0
var knockback: Vector2 = Vector2.ZERO

func apply_knockback(push_direction: Vector2, force: float) -> void:
	knockback = push_direction.normalized() * force



var health:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	progress_bar.max_value = max_health
	progress_bar.value = max_health
	player = get_tree().get_nodes_in_group("player")[0] as Player

func _physics_process(delta: float) -> void:
	if player != null:
		var enemy_to_player = (player.global_position - global_position)
		direction = enemy_to_player.normalized()
		if direction != Vector2.ZERO:
			velocity = speed * direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)

		velocity += knockback
		knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)

		move_and_slide()
	
func _process(_delta: float) -> void:
	look_at(player.global_position)

func take_damage(amount: int)->void:
	health -= amount
	progress_bar.value = health
	if health <= 0:
		die()

func die()->void:
	died.emit(global_position)
	call_deferred("_spawn_reward")
	queue_free()

func _spawn_reward() -> void:
	if coin_scene == null:
		return
	var coin := coin_scene.instantiate()
	coin.value = reward_value
	get_tree().get_first_node_in_group("game_root").add_child(coin)
	coin.global_position = global_position
