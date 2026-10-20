extends Node2D
## Mapa finito basado en Background.png: muros, límites, jugador centrado y spawner.

const WALL_THICKNESS := 32.0
const SPAWN_MARGIN := 80.0   # distancia extra fuera de la pantalla
const EDGE_PADDING := 16.0   # los enemigos no aparecen pegados al borde

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 100

@onready var background: Sprite2D = $Background
@onready var walls: StaticBody2D = $Walls
@onready var player = $Player

var map_rect := Rect2(0, 0, 1280, 720)


func _ready() -> void:
	# Rectángulo real del fondo, aunque tenga Centered u Offset
	if background.texture:
		var r := background.get_rect()
		map_rect = Rect2(
			background.global_position + r.position * background.global_scale,
			r.size * background.global_scale
		)
	_create_walls()
	player.global_position = map_rect.get_center()
	player.set_bounds(map_rect)
	_create_spawn_timer()


func _create_spawn_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)


func _on_spawn_timer_timeout() -> void:
	if enemy_scene == null:
		return
	if get_tree().get_nodes_in_group("enemy").size() >= max_enemies:
		return
	var enemy := enemy_scene.instantiate()
	enemy.player = player            # referencia directa al jugador
	enemy.position = _random_spawn_position()
	add_child(enemy)


## Busca un punto fuera de la pantalla pero dentro del mapa.
func _random_spawn_position() -> Vector2:
	var radius := get_viewport_rect().size.length() / 2.0 + SPAWN_MARGIN
	var inner := map_rect.grow(-EDGE_PADDING)
	# 1) Intenta un punto en círculo alrededor del jugador que caiga dentro del mapa
	for i in 12:
		var pos: Vector2 = player.global_position + Vector2.from_angle(randf() * TAU) * radius
		if inner.has_point(pos):
			return pos
	# 2) Si el jugador está en una esquina, cualquier punto lejano dentro del mapa
	for i in 12:
		var pos := Vector2(
			randf_range(inner.position.x, inner.end.x),
			randf_range(inner.position.y, inner.end.y)
		)
		if pos.distance_to(player.global_position) > 250.0:
			return pos
	return inner.get_center()


## Cuatro muros fuera del rectángulo del mapa (el nodo Walls debe estar en 0,0).
func _create_walls() -> void:
	var t := WALL_THICKNESS
	var x := map_rect.position.x
	var y := map_rect.position.y
	var w := map_rect.size.x
	var h := map_rect.size.y
	var defs := [
		[Vector2(x + w / 2.0, y - t / 2.0), Vector2(w + t * 2.0, t)],      # arriba
		[Vector2(x + w / 2.0, y + h + t / 2.0), Vector2(w + t * 2.0, t)],  # abajo
		[Vector2(x - t / 2.0, y + h / 2.0), Vector2(t, h + t * 2.0)],      # izquierda
		[Vector2(x + w + t / 2.0, y + h / 2.0), Vector2(t, h + t * 2.0)],  # derecha
	]
	for d in defs:
		var shape := RectangleShape2D.new()
		shape.size = d[1]
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = d[0]
		walls.add_child(col)
