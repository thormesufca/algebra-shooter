extends Node2D

@export var enemy_scene: PackedScene

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	var x_pos = randf_range(40, get_viewport_rect().size.x - 40)
	enemy.position = Vector2(x_pos, -20)
	add_child(enemy)
