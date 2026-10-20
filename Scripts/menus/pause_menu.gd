extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Permite que el menu sea usable con el juego pausado


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_renaudar_pressed() -> void:
	get_tree().paused = false # el juego vuelve a funcionar
	
	queue_free() # con esto borramos el menu añadido a la pantalla principal


func _on_btn_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
