extends CharacterBody2D


@export var speed: float = 400.0
@export var bullet_scene: PackedScene
@export var bullet_amount: float = 1
@export var bullet_speed: float = 800.0
@export var bullet_size: float = 10.0
@export var damage: float = 1.0
@export var score = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const DIRECTIONS := [
	"south", "se", "east", "ne",
	"north", "nw", "west", "sw"
]

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
	
func _process(delta: float) -> void:
		var dir := (get_global_mouse_position() - global_position).normalized()
		var angle := fmod(PI / 2 - dir.angle() + TAU, TAU)  # normaliza para 0..2π
		var index := int(round(angle / (TAU / 8.0))) % 8
		print(DIRECTIONS[index])
		var anim_name :String = "walk_" + DIRECTIONS[index]

		if sprite.animation != anim_name:
			sprite.play(anim_name)
	
func _on_shoot_timer_timeout() -> void:
	shoot()

func shoot() -> void:
	if bullet_scene == null:
		return
	var mouse_pos := get_global_mouse_position()
	var direction := (mouse_pos - global_position).normalized()
	var perpendicular := direction.rotated(PI / 2)

	var pos = (-bullet_amount / 2) * 10
	for i in range(bullet_amount):
		pos += i + 10
		var bullet = bullet_scene.instantiate()
		bullet.position = position + perpendicular * pos
		bullet.direction = direction
		bullet.rotation = direction.angle()
		bullet.speed = bullet_speed
		bullet.bullet_size = bullet_size
		bullet.damage = damage
		bullet.enemy_hit.connect(_on_bullet_enemy_hit)
		get_tree().current_scene.add_child(bullet)
		
func _on_bullet_enemy_hit() -> void:
	score += 1
	
func set_fire_rate(new_wait_time: float) -> void:
	$ShootTimer.wait_time = new_wait_time
