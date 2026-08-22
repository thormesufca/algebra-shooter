extends Area2D

## Se não for atribuído, é gerado com valores padrão em _ready().
@export var data: PowerupData

@onready var label: RichTextLabel = $ExpressionLabel
@onready var icon: AnimatedSprite2D = $Icon
@onready var icon_collision: CollisionShape2D = $CollisionShape2D

const ICON_LEFT_PADDING := 2.0
const TARGET_ICON_SIZE := 24.0

const LIFETIME := 10.0
const BLINK_DURATION := 3.0
const BLINK_INTERVAL := 0.15
const SCREEN_MARGIN := 4.0

const ExprToBBCode := preload("res://scripts/ExprToBBCode.gd")
const RichTextRaiseEffect := preload("res://scripts/raise.gd")
const BodyFont := preload("res://assets/fonts/CormorantGaramond-VariableFont_wght.ttf")

## Sons tocados quando pega powerup ou down.
const PowerupSfx := preload("res://assets/sounds/effects/powerup.wav")
const PowerdownSfx := preload("res://assets/sounds/effects/powerdown.wav")



var _alive := true

func _process(delta: float) -> void:
	# Powerup sobe para não ficar perdido em fases mais rápidas
	var camera := get_viewport().get_camera_2d()
	if camera != null and "scroll_speed" in camera:
		position.y -= camera.scroll_speed * 0.5 * delta

func _ready() -> void:
	if data == null:
		data = PowerupGenerator.generate()
	icon.sprite_frames = data.get_sprite_frames()
	icon.animation = "animated"
	icon.play()
	var frame_size := icon.sprite_frames.get_frame_texture("animated", 0).get_size()
	var uniform_scale := TARGET_ICON_SIZE / frame_size.x
	icon.scale = Vector2(uniform_scale, uniform_scale)
	label.bbcode_enabled = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.fit_content = true
	label.custom_minimum_size = Vector2(64, 30)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.install_effect(RichTextRaiseEffect.new())
	label.text = ExprToBBCode.expr_to_bbcode(data.expression)
	_apply_parchment_style()
	await get_tree().process_frame
	_align_icon_to_box()
	_clamp_to_screen()
	_start_lifetime()

func _align_icon_to_box() -> void:
	var icon_half_size := icon.sprite_frames.get_frame_texture(icon.animation, 0).get_size() * icon.scale / 2.0
	var box_center_y := label.position.y + label.size.y / 2.0
	var icon_pos := Vector2(label.position.x + ICON_LEFT_PADDING + icon_half_size.x, box_center_y)
	icon.position = icon_pos
	icon_collision.shape.size = label.size
	icon_collision.position = label.position + label.size / 2.0

#Evitar de ser gerado powerup fora da tela
func _clamp_to_screen() -> void:
	var icon_half_width: float = icon.sprite_frames.get_frame_texture(icon.animation, 0).get_size().x * icon.scale.x / 2.0
	var local_left: float = min(label.position.x, icon.position.x - icon_half_width)
	var local_right: float = max(label.position.x + label.size.x, icon.position.x + icon_half_width)

	var viewport_width := get_viewport_rect().size.x
	var min_x := SCREEN_MARGIN - local_left
	var max_x := viewport_width - SCREEN_MARGIN - local_right

	if min_x > max_x:
		global_position.x = (min_x + max_x) / 2.0
	else:
		global_position.x = clamp(global_position.x, min_x, max_x)


func _start_lifetime() -> void:
	var tree := get_tree()
	await tree.create_timer(LIFETIME - BLINK_DURATION).timeout
	if not _alive or not is_inside_tree():
		return
	var elapsed := 0.0
	#Piscar o powerup quando estiver perto de desaparecer
	while elapsed < BLINK_DURATION and _alive:
		visible = not visible
		await tree.create_timer(BLINK_INTERVAL).timeout
		if not is_inside_tree():
			return
		elapsed += BLINK_INTERVAL
	#Se após piscar, o jogador não pegou, chama função do jogador para incrementar o multiplicador
	if _alive and is_inside_tree():
		var player = tree.get_first_node_in_group("player")
		if player.has_method("giveup_powerup"):
			player.giveup_powerup()
		queue_free()

#Estilo de fundo do powerup
func _apply_parchment_style() -> void:
	var parchment := StyleBoxFlat.new()
	parchment.bg_color = Color(0.9137255, 0.8509804, 0.7137255, 1)
	parchment.border_color = Color(0.7137255, 0.5568628, 0.14509805, 1)
	parchment.set_border_width_all(2)
	parchment.set_corner_radius_all(8)
	parchment.content_margin_left = 30.0
	parchment.content_margin_top = 4.0
	parchment.content_margin_right = 8.0
	parchment.content_margin_bottom = 4.0
	label.add_theme_stylebox_override("normal", parchment)
	label.add_theme_font_override("normal_font", BodyFont)
	label.add_theme_font_override("bold_font", BodyFont)
	label.add_theme_font_size_override("normal_font_size", 24)
	label.add_theme_font_size_override("bold_font_size", 24)
	label.add_theme_color_override("default_color", Color(0.24313726, 0.15294118, 0.078431375, 1))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_alive = false
		_apply_powerup_effect(body)
		queue_free()

func _apply_powerup_effect(player: Node) -> void:
	if player.has_method("apply_powerup"):
		var pitch: float = PowerupData.PITCH_BY_ATTRIBUTE.get(data.attribute, 1.0)
		if data.result > 0:
			Sfx.play(PowerupSfx, 0.0, "Master", pitch)
		elif data.result < 0:
			Sfx.play(PowerdownSfx, 0.0, "Master", pitch)
		player.apply_powerup(data)
