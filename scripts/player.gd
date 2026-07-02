extends CharacterBody2D

class_name Player

signal died

@export var speed: float = 400.0
@export var bullet_scene: PackedScene
@export var bullet_amount: float = 1
@export var bullet_speed: float = 400.0
@export var bullet_size: float = 10.0
@export var damage: float = 3.0
@export var shield: int = 3
@export var magnet: float = 1.0
@export var score = 0
@export var coins: int = 0
var multiplicador: int = 1

## Acumulador float da "vida máxima" (mesma lógica percentual dos demais
## atributos). `shield` (a quantidade em jogo) vira floor(max_shield) no
## início de cada fase — ver start_new_phase().
var max_shield: float = 3.0

## Acumulador float da quantidade de flechas. Mesma lógica de floor do
## escudo, mas aplicada imediatamente em vez de esperar a próxima fase.
var bullet_amount_progress: float = 1.0
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_area: Area2D = $HurtArea

const DIRECTIONS := [
	"south", "se", "east", "ne",
	"north", "nw", "west", "sw"
]

const HIT_INVULNERABILITY_DURATION := 3.0
const HIT_BLINK_INTERVAL := 0.1
const KNOCKBACK_FRICTION := 600.0
const KNOCKBACK_FORCE := 220.0
const ENEMY_KNOCKBACK_FORCE := 280.0

var is_invulnerable: bool = false
var knockback: Vector2 = Vector2.ZERO

func _ready() -> void:
	hurt_area.body_entered.connect(_on_hurt_area_body_entered)

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	velocity = direction.normalized() * speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	move_and_slide()

	# Mantém o jogador dentro da tela
	position.x = clamp(position.x, 20, 840)
	position.y = clamp(position.y, -10000000, -400)

	move_and_slide()

func _on_hurt_area_body_entered(body: Node) -> void:
	if is_invulnerable:
		return
	if body.is_in_group("enemy"):
		_on_hit_by_enemy(body)

func _on_hit_by_enemy(enemy: Node) -> void:
	var push_dir : Vector2 = (global_position - enemy.global_position)
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.UP
	push_dir = push_dir.normalized()
	knockback = push_dir * KNOCKBACK_FORCE
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(-push_dir, ENEMY_KNOCKBACK_FORCE)

	shield = max(shield - 1, 0)
	if shield < 0:
		died.emit()
		return
	is_invulnerable = true
	_blink_while_invulnerable()

func _blink_while_invulnerable() -> void:
	var elapsed := 0.0
	while elapsed < HIT_INVULNERABILITY_DURATION:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(HIT_BLINK_INTERVAL).timeout
		elapsed += HIT_BLINK_INTERVAL
	sprite.visible = true
	is_invulnerable = false

func _process(delta: float) -> void:
		var dir := (get_global_mouse_position() - global_position).normalized()
		var angle := fmod(PI / 2 - dir.angle() + TAU, TAU)  # normaliza para 0..2π
		var index := int(round(angle / (TAU / 8.0))) % 8
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
		#shoot_sound.play()
		bullet.position = position + perpendicular * pos
		bullet.direction = direction
		bullet.rotation = direction.angle()
		bullet.speed = bullet_speed
		bullet.bullet_size = bullet_size
		bullet.damage = damage
		bullet.enemy_hit.connect(_on_bullet_enemy_hit)
		get_tree().get_first_node_in_group("game_root").add_child(bullet)
		
func _on_bullet_enemy_hit() -> void:
	score += 1

func add_coins(amount: int) -> void:
	coins += amount

func set_fire_rate(new_wait_time: float) -> void:
	$ShootTimer.wait_time = new_wait_time

## Aplica um PowerupData: acréscimo/decréscimo percentual sobre o atributo
## indicado. Shield e BulletAmount usam acumuladores float com floor
## (max_shield/bullet_amount_progress) em vez de aplicar direto sobre um
## valor já inteiro — Shield só reflete no jogo na próxima fase,
## BulletAmount reflete na hora.
func apply_powerup(data: PowerupData) -> void:
	var factor :float = 1.0 + (data.result * multiplicador / 100.0)
	multiplicador = 1
	match data.attribute:
		PowerupData.Attribute.DAMAGE:
			damage = max(damage * factor, 0.0)
		PowerupData.Attribute.SPEED:
			speed = max(speed * factor, 0.0)
		PowerupData.Attribute.FIRE_RATE:
			# Cadência positiva deve acelerar o disparo, então o fator
			# percentual reduz o wait_time em vez de aumentá-lo.
			var shoot_timer: Timer = $ShootTimer
			shoot_timer.wait_time = max(shoot_timer.wait_time / factor, 0.05)
		PowerupData.Attribute.SHIELD:
			max_shield = max(max_shield * factor, 0.0)
			# Perdas no máximo já refletem no escudo atual; ganhos só
			# valem a partir da próxima fase (start_new_phase()).
			shield = min(shield, int(floor(max_shield)))
		PowerupData.Attribute.MAGNET:
			magnet = max(magnet * factor, 0.0)
		PowerupData.Attribute.BULLET_AMOUNT:
			bullet_amount_progress = max(bullet_amount_progress * factor, 1.0)
			bullet_amount = floor(bullet_amount_progress)

# Player não pegou algum powerup, incrementa multiplicador
func giveup_powerup() -> void:
	multiplicador += 1
	

## Sincroniza o escudo em jogo com a vida máxima acumulada. Deve ser chamado
## no início de cada fase (ainda não há transição de fase implementada).
func start_new_phase() -> void:
	shield = int(floor(max_shield))
