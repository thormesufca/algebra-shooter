extends CharacterBody2D

class_name Player

signal died

const PowerupResultLabelScene := preload("res://entities/PowerupResultLabel.tscn")

@export var speed: float = 200.0
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
var max_multiplier: int = 3 #Teto multiplicador (setado pela fase)
var max_shield: float = 3.0 #Escudos
var bullet_amount_progress: float = 1.0 #Flechas
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound #Som de tiro (desativado)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var hurt_area: Area2D = $HurtArea #Hitbox para jogador

const HitSfx = preload("res://assets/sounds/effects/Strong Hit.wav") #Som quando é atingido
const KoSfx := preload("res://assets/sounds/effects/KO Male.wav") #Som quando é morto

const HIT_INVULNERABILITY_DURATION := 3.0 #Duração invulnerabilidade
const HIT_BLINK_INTERVAL := 0.1 #Intervalo de piscar
const KNOCKBACK_FRICTION := 600.0
const KNOCKBACK_FORCE := 220.0
const ENEMY_KNOCKBACK_FORCE := 280.0
const SCREEN_MARGIN := 40.0 

#Margens para limitar movimento lateral à imagem da parede
const MIN_X := 60.0 
const MAX_X := 800.0
const MOVING_SPEED_THRESHOLD := 1.0

#Máquina de estados
enum AnimState { IDLE, WALK, HURT, DEAD }
var anim_state: AnimState = AnimState.IDLE

var is_invulnerable: bool = false
var knockback: Vector2 = Vector2.ZERO
var is_dead: bool = false

func _ready() -> void:
	hurt_area.body_entered.connect(_on_hurt_area_body_entered)

#Movimento do jogador
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if not is_dead:
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")

	velocity = direction.normalized() * speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	move_and_slide()

	#Jogador não pode ultrapassar o campo de visão da câmera
	_clamp_to_camera_view()

#Seta a posição do jogador aos limites da câmera
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
	if body.is_in_group("enemy"):
		_on_hit_by_enemy(body)


#Evento quando inimigo atinge jogador
func _on_hit_by_enemy(enemy: Node) -> void:
	#Se estiver no estado invulerável, não faz nada
	if is_invulnerable:
		return

	#Calcula knockback
	var push_dir : Vector2 = (global_position - enemy.global_position)
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.UP
	push_dir = push_dir.normalized()
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(-push_dir, ENEMY_KNOCKBACK_FORCE)
	take_damage_from(enemy.global_position, push_dir)

#Função de receber dano
func take_damage_from(source_position: Vector2, push_dir: Vector2 = Vector2.ZERO) -> void:
	#Se estiver invulnerável ou morto, não faz nada
	if is_invulnerable or is_dead:
		return
	#Toca o som
	Sfx.play(HitSfx)
	
	#Calcula knockback
	if push_dir == Vector2.ZERO:
		push_dir = (global_position - source_position)
		if push_dir == Vector2.ZERO:
			push_dir = Vector2.UP
		push_dir = push_dir.normalized()
	knockback = push_dir * KNOCKBACK_FORCE

	#Se não tem mais escudo, morreu
	if shield <= 0:
		await _play_death_animation()
		died.emit()
		return
	
	#Se ainda tem escudo, decrementa, marca como invulnerável e chama função de piscar
	shield = max(shield - 1, 0)
	is_invulnerable = true
	_blink_while_invulnerable()


#Função para piscar quando invulnerável
func _blink_while_invulnerable() -> void:
	var tree := get_tree()
	var elapsed := 0.0
	while elapsed < HIT_INVULNERABILITY_DURATION:
		sprite.visible = not sprite.visible
		await tree.create_timer(HIT_BLINK_INTERVAL).timeout
		if not is_inside_tree():
			return
		elapsed += HIT_BLINK_INTERVAL
	sprite.visible = true

	#Quando terminar de piscar, marca invulnerável como falso
	is_invulnerable = false

#Processo a cada frame (calcula o ângulo em relação ao mouse e rotaciona o sprite) e verifica estados
func _process(_delta: float) -> void:
	var dir := (get_global_mouse_position() - global_position)
	sprite.rotation = dir.angle() 
	_update_animation_state()


#Transição entre estados
func _update_animation_state() -> void:
	#Se está morto, ignora, tem função específica
	if is_dead:
		return

	#Seta o próximo estado com base no atual
	var next_state: AnimState
	if is_invulnerable:
		next_state = AnimState.HURT
	elif velocity.length() > MOVING_SPEED_THRESHOLD:
		next_state = AnimState.WALK
	else:
		next_state = AnimState.IDLE

	#Se o próximo é igual ao atual, não transiciona
	if next_state == anim_state:
		return
	
	#Transiciona o estado
	anim_state = next_state
	
	#Altera a animação com base no estado atual (transicionado)
	match anim_state:
		AnimState.WALK:
			sprite.play("walk_shoot")
		AnimState.HURT:
			sprite.play("walk_hurt")
		AnimState.IDLE:
			sprite.play("idle_shoot")

#Função para rodar animação de morte
func _play_death_animation() -> void:
	is_dead = true
	anim_state = AnimState.DEAD
	$ShootTimer.stop() #Parar de atirar
	Sfx.play(KoSfx) #Som de morte
	sprite.play("death") #Animação de morte
	await sprite.animation_finished #Aguarda animação de morte terminar

func _on_shoot_timer_timeout() -> void:
	shoot()

#Atira flechas
func shoot() -> void:
	if bullet_scene == null:
		return
	var mouse_pos := get_global_mouse_position() #Pega posição do mouse
	var direction := (mouse_pos - global_position).normalized() #Calcula direção com base na posição do mouse e do jogador
	var perpendicular := direction.rotated(PI / 2)
	var pos = (-bullet_amount / 2) * 10 #Pequeno shift de posição a depender da quantidade de balas
	for i in range(bullet_amount):
		pos += i + 10
		var bullet = bullet_scene.instantiate()
		#shoot_sound.play()
		bullet.position = position + perpendicular * pos #Posição da flecha depende da quantidade
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

#Função para alterar o timer (cadência de tiro)
func set_fire_rate(new_wait_time: float) -> void:
	$ShootTimer.wait_time = new_wait_time

#Aplicar powerup de acordo com características de cada um
func apply_powerup(data: PowerupData) -> void:
	var value :float = data.result * multiplicador
	match data.attribute:
		PowerupData.Attribute.DAMAGE:
			damage = max(damage + value / 100.0, 0.0)
			_show_result_popup(data, multiplicador, value / 100)
		PowerupData.Attribute.SPEED:
			speed = max(speed + value, 0.0) #Velocidade aplica em valor bruto
			_show_result_popup(data, multiplicador, value)
		PowerupData.Attribute.FIRE_RATE:
			# Cadência positiva deve acelerar o disparo, então reduz o wait_time em vez de aumentar.
			var shoot_timer: Timer = $ShootTimer
			_show_result_popup(data, multiplicador, value / 1000)
			shoot_timer.wait_time = max(shoot_timer.wait_time - value / 10000.0, 0.05)
		#Escudo agora é comprado na loja, mantido para não quebrar caso adicione novamente
		PowerupData.Attribute.SHIELD:
			var old_shield = int(floor(max_shield))
			max_shield = max(max_shield + value / 100.0, 0.0)
			shield = min(shield, int(floor(max_shield)))
			if int(floor(max_shield)) > old_shield:
				shield += 1
			_show_result_popup(data, multiplicador, value / 100)
		PowerupData.Attribute.MAGNET:
			magnet = max(magnet + value / 100.0, 0.0)
			_show_result_popup(data, multiplicador, value / 100)
		#Flecha agora é comprada na loja, mantido para não quebrar caso adicione novamente
		PowerupData.Attribute.BULLET_AMOUNT:
			bullet_amount_progress = max(bullet_amount_progress + value / 100.0, 1.0)
			bullet_amount = floor(bullet_amount_progress)
			_show_result_popup(data, multiplicador, value / 100)
	multiplicador = 1 #Volta multiplicador a 1 quando pegar um powerup

#Popup para mostrar o valor resultado da expressão do powerup
func _show_result_popup(data: PowerupData, multiplier: int, effective_value: float) -> void:
	var popup := PowerupResultLabelScene.instantiate()
	popup.global_position = global_position
	get_tree().get_first_node_in_group("game_root").add_child(popup)
	popup.setup(data, multiplier, effective_value)

# Player não pegou algum powerup, incrementa multiplicador (até o teto da fase).
func giveup_powerup() -> void:
	multiplicador = min(multiplicador + 1, max_multiplier)
	


#Reseta os escudos no início da fase
func start_new_phase() -> void:
	shield = int(floor(max_shield))

#Monta dicionário com atributos do jogador
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

#Carregar os atributos do jogador do estado salvo
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
