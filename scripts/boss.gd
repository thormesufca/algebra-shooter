extends Enemy

class_name Boss
#Classe base para chefões (que herda de Enemy), com máquina de estado
enum State {MOVING, ENRAGING, ATTACKING, DYING}
var _state: State = State.MOVING
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var health_thresholds: Array[float] = [1.0, 0.5, 0.25, 0.1] # variações padrão de fase a depender da vida
var _last_threshold_stage: int = -1

const AngryBossSfx := preload("res://assets/sounds/effects/angry boss.mp3")
const ANGRY_PITCH_STEP := 0.12 # Passo em que o grito fica mais grave
const ANGRY_MIN_PITCH := 0.5

const DefaultDeathSfx := preload("res://assets/sounds/effects/boss_death.mp3")
@export var death_sound: AudioStream # null = usa o som padrão (boss_death)

## Grupo compartilhado para facilitar controle de projéteis lançados pelo boss
const PROJECTILE_GROUP := "boss_projectile"

##  Cada Boss concret deve chamar isso pra cada projétil que instancia
func _register_projectile(projectile: Node) -> void:
	projectile.add_to_group(PROJECTILE_GROUP)

func _ready() -> void:
	super._ready()
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	sprite.play("moving")

func _physics_process(_delta: float) -> void:
	pass

## Sobrescreve Enemy._process() de propósito: bosses não devem rotacionar ao se mover/patrulhar.
func _process(_delta: float) -> void:
	pass

#Devolver animação para estado movendo
func _on_sprite_animation_finished() -> void:
	if _state == State.ENRAGING or _state == State.ATTACKING:
		_set_state(State.MOVING)

func _set_state(new_state: State) -> void:
	if _state == State.DYING:
		return
	_state = new_state
	var anim_name := _animation_name_for_state(_state)
	if _has_animation(anim_name):
		sprite.play(anim_name)

#Todos as cenas de chefe têm que ter animações com esses nomes:
func _animation_name_for_state(state: State) -> String:
	match state:
		State.MOVING:
			return "moving"
		State.ENRAGING:
			return "enraging"
		State.ATTACKING:
			return "attacking"
		State.DYING:
			return "dying"
	return "moving"

#Verificar se a animação foi colocada no chefão
func _has_animation(anim_name: String) -> bool:
	return sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim_name)

#Identificar em que estágio o chefão está
func _health_threshold_stage() -> int:
	var health_fraction := float(health) / float(max_health) if max_health > 0 else 1.0
	var best_index := -1
	for i in range(health_thresholds.size()):
		if health_fraction <= health_thresholds[i]:
			if best_index == -1 or health_thresholds[i] < health_thresholds[best_index]:
				best_index = i
	return best_index

#Levou dano
func take_damage(amount: int) -> void:
	super.take_damage(amount)
	if _dying:
		return
	var stage := _health_threshold_stage()
	if stage > _last_threshold_stage:
		_last_threshold_stage = stage
		_on_threshold_crossed(stage)

#Mudança de estágio (tocar som)
func _on_threshold_crossed(stage: int) -> void:
	_set_state(State.ENRAGING)
	var pitch: float = max(1.0 - stage * ANGRY_PITCH_STEP, ANGRY_MIN_PITCH)
	Sfx.play(AngryBossSfx, 0.0, "Master", pitch)

#Quando o chefão morre, espera tocar a animação de morte antes de emitir o sinal died
func die() -> void:
	if _dying:
		return
	_dying = true
	_on_death_stop()
	for projectile in get_tree().get_nodes_in_group(PROJECTILE_GROUP): # Apagar os projéteis lançados durante a batalha
		projectile.queue_free()
	var death_player := Sfx.play(death_sound if death_sound != null else DefaultDeathSfx)
	var has_dying_animation := _has_animation("dying")
	_set_state(State.DYING)
	if has_dying_animation:
		await sprite.animation_finished
	
	#Aguardar o áudio de morte terminar
	if death_player != null and is_instance_valid(death_player) and death_player.playing:
		await death_player.finished
	died.emit(global_position)
	call_deferred("_spawn_reward")
	queue_free()

func _on_death_stop() -> void:
	pass
