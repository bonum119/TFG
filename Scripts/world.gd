extends Node2D
## Mapa finito de 1280x720 con muros invisibles y límites de cámara.

const MAP_SIZE := Vector2i(1280, 720)
const WALL_THICKNESS := 32.0

@onready var walls: StaticBody2D = $Walls
@onready var player = $Player


func _ready() -> void:
	_create_walls()
	player.set_camera_limits(Rect2i(Vector2i.ZERO, MAP_SIZE))


func _create_walls() -> void:
	var w := float(MAP_SIZE.x)
	var h := float(MAP_SIZE.y)
	var t := WALL_THICKNESS
	# [centro, tamaño] de cada borde (fuera del área jugable)
	var defs := [
		[Vector2(w / 2.0, -t / 2.0), Vector2(w + t * 2.0, t)],      # arriba
		[Vector2(w / 2.0, h + t / 2.0), Vector2(w + t * 2.0, t)],   # abajo
		[Vector2(-t / 2.0, h / 2.0), Vector2(t, h + t * 2.0)],      # izquierda
		[Vector2(w + t / 2.0, h / 2.0), Vector2(t, h + t * 2.0)],   # derecha
	]
	for d in defs:
		var shape := RectangleShape2D.new()
		shape.size = d[1]
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = d[0]
		walls.add_child(col)
