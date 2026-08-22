extends Resource

class_name PowerupData

enum Attribute { DAMAGE, SPEED, FIRE_RATE, SHIELD, MAGNET, BULLET_AMOUNT }

@export var attribute: Attribute = Attribute.DAMAGE
@export var expression: String = ""
@export var result: float = 0.0
@export var operator_level: int = 3
@export var digit_level: int = 6

#Pitchs para variar quando pegar powerups
const PITCH_BY_ATTRIBUTE := {
	Attribute.DAMAGE: 0.9,
	Attribute.FIRE_RATE: 1.10,
	Attribute.BULLET_AMOUNT: 1.0,
	Attribute.SHIELD: 1.0,
	Attribute.MAGNET: 1.05,
	Attribute.SPEED: 0.95,
}

#Dicionário com os ícones de cada powerup
const ICON_LAYOUT := {
	Attribute.DAMAGE: {"texture": "res://assets/sprites/powers/Muscle.png", "frame_size": Vector2i(24, 24), "columns": 4, "rows": 1},
	Attribute.FIRE_RATE: {"texture": "res://assets/sprites/powers/Arrow Dash.png", "frame_size": Vector2i(48, 48), "columns": 4, "rows": 1},
	Attribute.BULLET_AMOUNT: {"texture": "res://assets/sprites/powers/Quiver.png", "frame_size": Vector2i(24, 24), "columns": 4, "rows": 1},
	Attribute.SHIELD: {"texture": "res://assets/sprites/powers/Shield.png", "frame_size": Vector2i(24, 24), "columns": 2, "rows": 2},
	Attribute.MAGNET: {"texture": "res://assets/sprites/powers/Magnet.png", "frame_size": Vector2i(48, 48), "columns": 4, "rows": 1},
	Attribute.SPEED: {"texture": "res://assets/sprites/powers/Speed.png", "frame_size": Vector2i(48,48), "columns": 4, "rows": 1}
}

#Gerar sprites a partir do powerup
func get_sprite_frames() -> SpriteFrames:
	var layout: Dictionary = ICON_LAYOUT[attribute]
	var atlas: Texture2D = load(layout["texture"])
	var frame_size: Vector2i = layout["frame_size"]

	var frames := SpriteFrames.new()
	frames.add_animation("animated")
	frames.set_animation_loop("animated", true)
	frames.set_animation_speed("animated", 5.0)

	for row in range(layout["rows"]):
		for col in range(layout["columns"]):
			var region := Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = atlas
			atlas_texture.region = region
			frames.add_frame("animated", atlas_texture)

	return frames
