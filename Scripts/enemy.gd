extends CharacterBody2D

@export var speed: float = 60.0
@export var health: float = 3.0                  # CAMBIO
@export var knockback_decay: float = 900.0       # CAMBIO: rapidez con la que se apaga el retroceso
@export var separation_radius: float = 24.0
@export var separation_strength: float = 1.0
@export var player_push_radius: float = 22.0
@export var player_push_strength: float = 2.5
@export var anim_speed_variation: float = 0.15

@onready var sprite: AnimatedSprite2D = $Sprite

var player: Node2D
var has_directions := false
var has_west := false
var knockback := Vector2.ZERO


func _ready() -> void:
	add_to_group("enemy")
	motion_mode = MOTION_MODE_FLOATING
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	has_directions = sprite.sprite_frames.has_animation("walk_down")
	has_west = sprite.sprite_frames.has_animation("walk_west")

	sprite.speed_scale = 1.0 + randf_range(-anim_speed_variation, anim_speed_variation)
	sprite.play(_pick_animation(Vector2.DOWN))
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count(sprite.animation)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player / dist if dist > 0.001 else Vector2.ZERO

	var steer := dir
	if dist < player_push_radius or knockback.length() > 60.0:
		steer = Vector2.ZERO
		GameManager.take_life(5)
		

	var push := Vector2.ZERO
	var current_tree := get_tree()
	if current_tree == null:
		return
		
	for other in get_tree().get_nodes_in_group("enemy"):
		if other == self:
			continue
		var offset: Vector2 = global_position - other.global_position
		var d := offset.length()
		if d > 0.001 and d < separation_radius:
			push += (offset / d) * (1.0 - d / separation_radius) * separation_strength

	if dist < player_push_radius and dist > 0.001:
		push += -dir * (1.0 - dist / player_push_radius) * player_push_strength

	velocity = ((steer + push) * speed).limit_length(speed * 2.0) + knockback
	knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()

	_update_animation(dir)


func take_damage(amount: float, from_pos: Vector2, force: float) -> void:
	health -= amount
	var away := global_position - from_pos
	knockback = (away.normalized() if away.length() > 0.001 else Vector2.RIGHT) * force
	# Destello rojo
	sprite.modulate = Color(1.0, 0.4, 0.4)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
	if health <= 0.0:
		queue_free()


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	var anim := _pick_animation(dir)
	if sprite.animation != anim:
		var current_frame := sprite.frame
		sprite.play(anim)
		sprite.frame = current_frame

	if not has_directions:
		sprite.flip_h = dir.x < 0.0
	elif anim == "walk_east" and not has_west:
		sprite.flip_h = dir.x < 0.0
	else:
		sprite.flip_h = false

#DEPENDIENDO DE DONDE MIRE MUESTRA UN SPRITE O OTRO
func _pick_animation(dir: Vector2) -> String:
	if not has_directions:
		return "walk"
	if absf(dir.x) >= absf(dir.y):
		if dir.x < 0.0 and has_west:
			return "walk_west"
		return "walk_east"
	return "walk_down" if dir.y > 0.0 else "walk_up"
