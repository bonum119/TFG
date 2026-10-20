extends CharacterBody2D
## Jugador top-down con 4 direcciones.

@export var speed: float = 150.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera

const HALF_SIZE := 8.0   # medio tamaño del jugador para no pisar el borde

var last_direction: String = "down"  # "down", "up", "east" o "west"
var facing_west: bool = false
var has_west: bool = false           
var bounds := Rect2()
var has_bounds := false



func _ready() -> void:
	add_to_group("player")
	motion_mode = MOTION_MODE_FLOATING
	has_west = sprite.sprite_frames.has_animation("walk_west") \
			and sprite.sprite_frames.has_animation("idle_west")
	print("Animaciones: ", sprite.sprite_frames.get_animation_names(), " | has_west: ", has_west)


func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	move_and_slide()
	if has_bounds:
		global_position = global_position.clamp(
			bounds.position + Vector2(HALF_SIZE, HALF_SIZE),
			bounds.end - Vector2(HALF_SIZE, HALF_SIZE)
		)
	_update_animation(input_dir)


func _update_animation(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		if absf(dir.x) >= absf(dir.y):
			if dir.x < 0.0 and has_west:
				last_direction = "west"
			else:
				last_direction = "east"
			facing_west = dir.x < 0.0
		else:
			last_direction = "down" if dir.y > 0.0 else "up"
			facing_west = false
		_play("walk")
	else:
		_play("idle")


func _play(state: String) -> void:
	sprite.flip_h = (last_direction == "east" and facing_west)
	var anim := "%s_%s" % [state, last_direction]
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


func set_bounds(rect: Rect2) -> void:
	bounds = rect
	has_bounds = true
	camera.limit_left = int(rect.position.x)
	camera.limit_top = int(rect.position.y)
	camera.limit_right = int(rect.end.x)
	camera.limit_bottom = int(rect.end.y)
	
	
	
