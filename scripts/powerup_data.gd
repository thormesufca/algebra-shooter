extends Resource

class_name PowerupData

## Qual atributo do jogador esse powerup afeta. Também dita o ícone exibido.
## SPEED (velocidade de movimento do player) ainda não tem sprite/animação
## própria — ver PowerupGenerator.GENERATABLE_ATTRIBUTES.
enum Attribute { DAMAGE, SPEED, FIRE_RATE, SHIELD, MAGNET, BULLET_AMOUNT }

@export var attribute: Attribute = Attribute.DAMAGE
## Texto exibido no card (mesmo formato aceito por ExprToBBCode: ^, sqrt(...)).
@export var expression: String = ""
## Resultado numérico da expressão — é o valor percentual aplicado ao atributo.
@export var result: float = 0.0
## Nível de operadores desbloqueado no momento da geração (1: + -, 2: + - x /, 3: + - x / ^ sqrt).
@export var operator_level: int = 1
## Maior dígito disponível no momento da geração (inicia em 4, compra até 9).
@export var digit_level: int = 4

## Layout de cada spritesheet: tamanho do frame e quantas colunas/linhas ele
## ocupa (frames lidos em ordem linha a linha, esquerda->direita).
const ICON_LAYOUT := {
	Attribute.DAMAGE: {"texture": "res://assets/sprites/powers/Muscle.png", "frame_size": Vector2i(24, 24), "columns": 4, "rows": 1},
	Attribute.FIRE_RATE: {"texture": "res://assets/sprites/powers/Arrow Dash.png", "frame_size": Vector2i(48, 48), "columns": 4, "rows": 1},
	Attribute.BULLET_AMOUNT: {"texture": "res://assets/sprites/powers/Quiver.png", "frame_size": Vector2i(24, 24), "columns": 4, "rows": 1},
	Attribute.SHIELD: {"texture": "res://assets/sprites/powers/Shield.png", "frame_size": Vector2i(24, 24), "columns": 2, "rows": 2},
	Attribute.MAGNET: {"texture": "res://assets/sprites/powers/Magnet.png", "frame_size": Vector2i(48, 48), "columns": 4, "rows": 1},
}

## Monta um SpriteFrames com a animação "animated" para o atributo, lendo o
## layout (linhas x colunas) declarado em ICON_LAYOUT.
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
