extends CharacterBody2D


@export var speed: float = 400.0
@export var bullet_scene: PackedScene
@export var bullet_amount: float = 1
@export var bullet_speed: float = 800.0
@export var bullet_size: float = 1.0
@export var score = 0


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	velocity = direction.normalized() * speed
	move_and_slide()
	
	# Mantém o jogador dentro da tela
	position.x = clamp(position.x, 20, get_viewport_rect().size.x - 20)
	position.y = clamp(position.y, 20, get_viewport_rect().size.y - 20)

	move_and_slide()
	
func _on_shoot_timer_timeout() -> void:
	shoot()

func shoot() -> void:
	if bullet_scene == null:
		return
	var pos = (-bullet_amount / 2) * 10
	for i in range(bullet_amount):
		pos += i + 10
		var bullet = bullet_scene.instantiate()
		bullet.position = position + Vector2(pos, -30)
		bullet.speed = bullet_speed
		bullet.bullet_size = bullet_size
		bullet.enemy_hit.connect(_on_bullet_enemy_hit)
		get_tree().current_scene.add_child(bullet)
		
func _on_bullet_enemy_hit() -> void:
	score += 1
	bullet_speed += 5
	bullet_size += 0.01
	if(score % 20 == 0):
		var vel = $ShootTimer.wait_time
		set_fire_rate(vel - 0.1)
		print("Score: ", score)
		print("Nova Velocidade de Tiro: ", $ShootTimer.wait_time)
	
func set_fire_rate(new_wait_time: float) -> void:
	$ShootTimer.wait_time = new_wait_time
