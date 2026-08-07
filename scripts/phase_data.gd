extends Resource

class_name PhaseData

@export var phase_name: String = "Fase 1"
@export var operators_unlocked: String = "+ -"

@export_group("Spawn")
@export var enemy_scene: PackedScene
## Pool de inimigos da fase: se preenchido, cada spawn sorteia uma cena
## aleatória desta lista em vez de sempre usar enemy_scene, permitindo
## vários tipos de inimigo convivendo na mesma fase.
@export var enemy_scenes: Array[PackedScene] = []
@export var power_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var powerup_enemy_index: int = 5
## Estágios de dificuldade ao longo da fase: conforme a câmera percorre a
## distância, o estágio com o maior distance_threshold já alcançado passa a
## valer, trocando spawn_interval e/ou enemy_scene.
@export var spawn_stages: Array[SpawnStage] = [SpawnStage.new()]

@export_group("Câmera")
## Velocidade constante (px/s) com que a câmera avança automaticamente.
@export var camera_speed: float = 60.0
## Distância total (px) que a câmera percorre até a fase ser concluída.
@export var phase_distance: float = 50000.0

@export_group("Boss")
## Cena do boss da fase: spawna depois que a câmera termina o percurso E os
## inimigos comuns restantes morrem (ver game.gd/_run_boss_sequence). Se
## null, a fase não tem boss dedicado (ainda usa o boss antigo via
## spawn_stages, ou não tem boss).
@export var boss_scene: PackedScene

@export_group("Fundo")
## Tint aplicado sobre a névoa (bg_fog.png) — mantenha alpha baixo, é uma
## camada translúcida, não um fundo sólido.
@export var sky_color: Color = Color(0.7137255, 0.68235296, 0.827451, 0.5)
@export var walls_color: Color = Color(0.24705882, 0.19607843, 0.15686275, 0.85)
@export var floor_color: Color = Color(0.41960785, 0.3372549, 0.24313726, 1)
