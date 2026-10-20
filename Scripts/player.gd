extends CharacterBody2D
## Jugador top-down con 4 direcciones.
## West = East espejado (flip_h).

@export var speed: float = 150.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera

var last_direction: String = "down"  # "down", "up" o "east"
var facing_west: bool = false


func _physics_process(_delta: float) -> void:
	# get_vector ya devuelve un vector normalizado (sin ventaja en diagonales)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	move_and_slide()
	_update_animation(input_dir)


func _update_animation(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		# El eje dominante decide hacia dónde mira (en diagonal exacta gana el horizontal)
		if absf(dir.x) >= absf(dir.y):
			last_direction = "east"
			facing_west = dir.x < 0.0
		else:
			last_direction = "down" if dir.y > 0.0 else "up"
			facing_west = false
		_play("walk")
	else:
		_play("idle")


func _play(state: String) -> void:
	# El flip solo se aplica en horizontal; arriba/abajo siempre sin flip
	sprite.flip_h = (last_direction == "east" and facing_west)
	var anim := "%s_%s" % [state, last_direction]
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
	add_to_group("player")


## Llamado desde World para fijar los límites de la cámara.
func set_camera_limits(rect: Rect2i) -> void:
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
