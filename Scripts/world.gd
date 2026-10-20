extends Node2D
## Mapa finito basado en Background.png, con muros, límites de cámara y spawner.

const WALL_THICKNESS := 32.0
const SPAWN_MARGIN := 60.0

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 100

@onready var background: Sprite2D = $Background
@onready var walls: StaticBody2D = $Walls
@onready var player = $Player

var map_size := Vector2i(1280, 720)


func _ready() -> void:
	if background.texture:
		map_size = Vector2i(background.texture.get_size())
	_create_walls()
	player.set_camera_limits(Rect2i(Vector2i.ZERO, map_size))
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
	enemy.position = _random_spawn_position()
	add_child(enemy)


## Posición en un círculo justo fuera de la pantalla, alrededor del jugador,
## limitada al interior del mapa.
func _random_spawn_position() -> Vector2:
	var radius := get_viewport_rect().size.length() / 2.0 + SPAWN_MARGIN
	var pos: Vector2 = player.global_position + Vector2.from_angle(randf() * TAU) * radius
	pos.x = clampf(pos.x, 0.0, float(map_size.x))
	pos.y = clampf(pos.y, 0.0, float(map_size.y))
	return pos


func _create_walls() -> void:
	var w := float(map_size.x)
	var h := float(map_size.y)
	var t := WALL_THICKNESS
	var defs := [
		[Vector2(w / 2.0, -t / 2.0), Vector2(w + t * 2.0, t)],
		[Vector2(w / 2.0, h + t / 2.0), Vector2(w + t * 2.0, t)],
		[Vector2(-t / 2.0, h / 2.0), Vector2(t, h + t * 2.0)],
		[Vector2(w + t / 2.0, h / 2.0), Vector2(t, h + t * 2.0)],
	]
	for d in defs:
		var shape := RectangleShape2D.new()
		shape.size = d[1]
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = d[0]
		walls.add_child(col)
