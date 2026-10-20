extends CharacterBody2D
## Enemigo básico: persigue al jugador en línea recta.

@export var speed: float = 60.0

@onready var sprite = $Sprite

var player: Node2D


func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	var dir := global_position.direction_to(player.global_position)
	velocity = dir * speed
	move_and_slide()
	# Mira hacia el jugador (asume que el sprite original mira a la derecha)
	if absf(dir.x) > 0.01:
		sprite.flip_h = dir.x < 0.0
