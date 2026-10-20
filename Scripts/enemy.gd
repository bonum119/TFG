extends CharacterBody2D
## Enemigo animado: persigue al jugador, se separa de otros enemigos
## y es desplazado por el jugador al atravesarlo.

@export var speed: float = 60.0
@export var separation_radius: float = 24.0
@export var separation_strength: float = 1.0
@export var player_push_radius: float = 22.0
@export var player_push_strength: float = 2.5
@export var anim_speed_variation: float = 0.15   # desincroniza las animaciones entre enemigos

@onready var sprite: AnimatedSprite2D = $Sprite

var player: Node2D   # lo asigna World al hacer spawn
var has_directions := false


func _ready() -> void:
	add_to_group("enemy")
	motion_mode = MOTION_MODE_FLOATING
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	# Modo 4 direcciones si existen esas animaciones; si no, usa "walk" con flip
	has_directions = sprite.sprite_frames.has_animation("walk_down")

	# Cada enemigo empieza en un frame distinto y a velocidad ligeramente distinta
	sprite.speed_scale = 1.0 + randf_range(-anim_speed_variation, anim_speed_variation)
	sprite.play(_pick_animation(Vector2.DOWN))
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count(sprite.animation)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player / dist if dist > 0.001 else Vector2.ZERO

	var steer := dir
	if dist < player_push_radius:
		steer = Vector2.ZERO

	var push := Vector2.ZERO
	for other in get_tree().get_nodes_in_group("enemy"):
		if other == self:
			continue
		var offset: Vector2 = global_position - other.global_position
		var d := offset.length()
		if d > 0.001 and d < separation_radius:
			push += (offset / d) * (1.0 - d / separation_radius) * separation_strength

	if dist < player_push_radius and dist > 0.001:
		push += -dir * (1.0 - dist / player_push_radius) * player_push_strength

	velocity = ((steer + push) * speed).limit_length(speed * 2.0)
	move_and_slide()

	_update_animation(dir)


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	var anim := _pick_animation(dir)
	if sprite.animation != anim:
		var current_frame := sprite.frame
		sprite.play(anim)
		sprite.frame = current_frame   # evita el "salto" al cambiar de dirección

	# Espejado: solo cuando mira a la izquierda en la animación lateral
	if has_directions:
		sprite.flip_h = (anim == "walk_east" and dir.x < 0.0)
	else:
		sprite.flip_h = dir.x < 0.0


func _pick_animation(dir: Vector2) -> String:
	if not has_directions:
		return "walk"
	if absf(dir.x) >= absf(dir.y):
		return "walk_east"
	return "walk_down" if dir.y > 0.0 else "walk_up"
