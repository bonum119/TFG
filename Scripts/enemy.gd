extends CharacterBody2D
## Enemigo: persigue al jugador, se separa de otros enemigos
## y es desplazado por el jugador al atravesarlo.

@export var speed: float = 60.0
@export var separation_radius: float = 24.0    # distancia mínima deseada entre enemigos
@export var separation_strength: float = 1.0   # fuerza de repulsión entre enemigos
@export var player_push_radius: float = 22.0   # zona en la que el jugador empuja
@export var player_push_strength: float = 2.5  # fuerza del empuje del jugador

@onready var sprite: Sprite2D = $Sprite

var player: Node2D   # lo asigna World al hacer spawn


func _ready() -> void:
	add_to_group("enemy")
	motion_mode = MOTION_MODE_FLOATING   # modo correcto para top-down
	if player == null:
		player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player / dist if dist > 0.001 else Vector2.ZERO

	# 1) Perseguir al jugador (se detiene si ya está "encima" para no temblar)
	var steer := dir
	if dist < player_push_radius:
		steer = Vector2.ZERO

	# 2) Separación respecto a otros enemigos
	var push := Vector2.ZERO
	for other in get_tree().get_nodes_in_group("enemy"):
		if other == self:
			continue
		var offset: Vector2 = global_position - other.global_position
		var d := offset.length()
		if d > 0.001 and d < separation_radius:
			push += (offset / d) * (1.0 - d / separation_radius) * separation_strength

	# 3) El jugador empuja a los enemigos que atraviesa
	if dist < player_push_radius and dist > 0.001:
		push += -dir * (1.0 - dist / player_push_radius) * player_push_strength

	velocity = (steer + push) * speed
	velocity = velocity.limit_length(speed * 2.0)
	move_and_slide()

	if absf(dir.x) > 0.01:
		sprite.flip_h = dir.x < 0.0
