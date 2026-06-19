extends Area2D

class_name Enemy

signal died(death_position: Vector2)


@export var max_health: int = 5

var health:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health

func take_damage(amount: int)->void:
	health -= amount
	if health <= 0:
		die()

func die()->void:
	died.emit(global_position)
	queue_free()
