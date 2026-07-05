extends Resource

class_name SpawnStage

## A distância percorrida pela câmera (em px) a partir da qual esse estágio
## passa a valer. Estágios são avaliados pelo maior distance_threshold que
## já foi alcançado.
@export var distance_threshold: float = 0.0
@export var spawn_interval: float = 1.0
## Se definido, substitui o enemy_scene da fase a partir deste estágio.
@export var enemy_scene: PackedScene
## Se preenchido, substitui o pool de inimigos da fase a partir deste
## estágio: cada spawn sorteia uma cena aleatória desta lista.
@export var enemy_scenes: Array[PackedScene] = []
## Sobrescreve o HP do inimigo instanciado neste estágio. -1 = mantém o valor
## padrão da cena do inimigo.
@export var enemy_health: int = -1
## Sobrescreve a recompensa (moedas) do inimigo instanciado neste estágio.
## -1 = mantém o valor padrão da cena do inimigo.
@export var enemy_reward: int = -1
## Sobrescreve a velocidade de movimento do inimigo neste estágio. -1 =
## mantém o valor padrão da cena do inimigo.
@export var enemy_speed: float = -1.0

func _init(_distance: float = 0.0, _spawn_interval: float = 1.0, enemy: PackedScene = null, _enemy_health: int = -1, _enemy_reward: int = -1, _enemy_speed: float = -1.0):
	distance_threshold = _distance
	spawn_interval = _spawn_interval
	enemy_scene = enemy
	enemy_health = _enemy_health
	enemy_reward = _enemy_reward
	enemy_speed = _enemy_speed
