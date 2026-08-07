extends CharacterBody2D

class_name Player

signal died

const PowerupResultLabelScene := preload("res://entities/PowerupResultLabel.tscn")

@export var speed: float = 400.0
@export var bullet_scene: PackedScene
@export var bullet_amount: float = 1
@export var bullet_speed: float = 400.0
@export var bullet_size: float = 10.0
@export var damage: float = 4.0
@export var shield: int = 3
@export var magnet: float = 1.0
@export var score = 0
@export var gold: int = 0
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
const SCREEN_MARGIN := 40.0
const MIN_X := 60.0
const MAX_X := 800.0

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

	_clamp_to_camera_view()

func _clamp_to_camera_view() -> void:
	position.x = clamp(position.x, MIN_X, MAX_X)

	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var half_height := get_viewport_rect().size.y / 2.0
	var min_y := camera.global_position.y - half_height + SCREEN_MARGIN
	var max_y := camera.global_position.y + half_height - SCREEN_MARGIN
	position.y = clamp(position.y, min_y, max_y)

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
	
	if shield <= 0:
		died.emit()
		return
	shield = max(shield - 1, 0)
	is_invulnerable = true
	_blink_while_invulnerable()

func _blink_while_invulnerable() -> void:
	# Guarda a SceneTree numa variável local: se a fase terminar com sucesso
	# durante o piscar (ver game.gd._finish_phase()), a cena troca para o
	# menu e este nó sai da árvore — get_tree() passaria a retornar null nos
	# awaits seguintes.
	var tree := get_tree()
	var elapsed := 0.0
	while elapsed < HIT_INVULNERABILITY_DURATION:
		sprite.visible = not sprite.visible
		await tree.create_timer(HIT_BLINK_INTERVAL).timeout
		if not is_inside_tree():
			return
		elapsed += HIT_BLINK_INTERVAL
	sprite.visible = true
	is_invulnerable = false

func _process(_delta: float) -> void:
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

func add_gold(amount: int) -> void:
	gold += amount

func set_fire_rate(new_wait_time: float) -> void:
	$ShootTimer.wait_time = new_wait_time

## Aplica um PowerupData: acréscimo/decréscimo aditivo sobre o atributo
## indicado, a partir de value = resultado da expressão * multiplicador.
## Todos os atributos somam value/100, exceto Velocidade (soma value direto).
## Shield e BulletAmount usam acumuladores float com floor
## (max_shield/bullet_amount_progress) em vez de aplicar direto sobre um
## valor já inteiro — Shield só reflete no jogo na próxima fase,
## BulletAmount reflete na hora.
func apply_powerup(data: PowerupData) -> void:
	var value :float = data.result * multiplicador
	match data.attribute:
		PowerupData.Attribute.DAMAGE:
			damage = max(damage + value / 100.0, 0.0)
			_show_result_popup(data, multiplicador, value / 100)
		PowerupData.Attribute.SPEED:
			speed = max(speed + value, 0.0)
			_show_result_popup(data, multiplicador, value)
		PowerupData.Attribute.FIRE_RATE:
			# Cadência positiva deve acelerar o disparo, então reduz o
			# wait_time em vez de aumentá-lo.
			var shoot_timer: Timer = $ShootTimer
			_show_result_popup(data, multiplicador, value / 1000)
			shoot_timer.wait_time = max(shoot_timer.wait_time - value / 1000.0, 0.05)
		PowerupData.Attribute.SHIELD:
			var old_shield = int(floor(max_shield))
			max_shield = max(max_shield + value / 100.0, 0.0)
				
			# Perdas no máximo já refletem no escudo atual; ganhos só
			# valem a partir da próxima fase (start_new_phase()).
			shield = min(shield, int(floor(max_shield)))
			# Se aumentou a quantidade de shields máxima, adiciona um shield de imediato
			if int(floor(max_shield)) > old_shield:
				shield += 1
			_show_result_popup(data, multiplicador, value / 100)
		PowerupData.Attribute.MAGNET:
			magnet = max(magnet + value / 100.0, 0.0)
			_show_result_popup(data, multiplicador, value / 100)
		PowerupData.Attribute.BULLET_AMOUNT:
			bullet_amount_progress = max(bullet_amount_progress + value / 100.0, 1.0)
			bullet_amount = floor(bullet_amount_progress)
			_show_result_popup(data, multiplicador, value / 100)
	multiplicador = 1
func _show_result_popup(data: PowerupData, multiplier: int, effective_value: float) -> void:
	var popup := PowerupResultLabelScene.instantiate()
	popup.global_position = global_position
	get_tree().get_first_node_in_group("game_root").add_child(popup)
	popup.setup(data, multiplier, effective_value)

# Player não pegou algum powerup, incrementa multiplicador
func giveup_powerup() -> void:
	multiplicador += 1
	

## Sincroniza o escudo em jogo com a vida máxima acumulada. Deve ser chamado
## no início de cada fase.
func start_new_phase() -> void:
	shield = int(floor(max_shield))

## Atributos ganhos via powerups (não os valores base do @export), para
## persistir entre fases como o campo `player` de um GameData — ver
## game.gd/GameSave. Só deve ser chamado quando a fase é concluída com
## sucesso.
func get_save_data() -> Dictionary:
	return {
		"damage": damage,
		"speed": speed,
		"fire_rate": $ShootTimer.wait_time,
		"max_shield": max_shield,
		"bullet_amount_progress": bullet_amount_progress,
		"magnet": magnet,
		"score": score,
		"gold": gold,
	}

## Restaura os atributos salvos por get_save_data() (campo `player` do
## GameData carregado). Chamado por game.gd no início de cada fase; se ainda
## não houver save, o dicionário vem vazio e os valores padrão do @export
## são mantidos.
func apply_save_data(data: Dictionary) -> void:
	damage = data.get("damage", damage)
	speed = data.get("speed", speed)
	max_shield = data.get("max_shield", max_shield)
	bullet_amount_progress = data.get("bullet_amount_progress", bullet_amount_progress)
	bullet_amount = floor(bullet_amount_progress)
	magnet = data.get("magnet", magnet)
	score = data.get("score", score)
	gold = data.get("gold", gold)
	set_fire_rate(data.get("fire_rate", $ShootTimer.wait_time))
	start_new_phase()
