extends Resource

class_name PhaseData

@export var phase_name: String = "Fase 1"
@export var operators_unlocked: String = "+ -"

@export_group("Spawn")
@export var enemy_scene: PackedScene
@export var power_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var powerup_enemy_index: int = 5

@export_group("Fundo")
## Tint aplicado sobre a névoa (bg_fog.png) — mantenha alpha baixo, é uma
## camada translúcida, não um fundo sólido.
@export var sky_color: Color = Color(0.7137255, 0.68235296, 0.827451, 0.5)
@export var walls_color: Color = Color(0.24705882, 0.19607843, 0.15686275, 0.85)
@export var floor_color: Color = Color(0.41960785, 0.3372549, 0.24313726, 1)
