extends Node2D
## Cofre: se abre al acercarse el jugador.

signal opened  #Aun no hay recompensa, luego lo añadimos jeje

@export var open_radius: float = 24.0

var player: Node2D
var is_opened := false


func _ready() -> void:
	add_to_group("chest")
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if is_opened or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) < open_radius:
		is_opened = true
		opened.emit()
		print("¡Cofre abierto!")   # Aun nada
		queue_free()
