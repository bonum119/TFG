extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal life_change (new_life: int)

var max_life :int = 100
var actual_life :int = 100

################# PLAYER FUNCTIONS #################

###### LIFE #########
func take_life(amount: int) -> void:
	actual_life -= amount
	if actual_life < 0: 
		actual_life = 0
	
	if actual_life == 0:
		morir()
		
	emit_signal("life_change", actual_life) #esto manda una señal al objeto barra_vida


func reiniciar() -> void:
	actual_life = max_life
	emit_signal("life_change", actual_life)
	
func morir() -> void:
	get_tree().paused = false
	reiniciar()
	get_tree().change_scene_to_file("res://Escenas/game_over.tscn")
