extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = GameManager.max_life
	value = GameManager.actual_life
	
	GameManager.life_change.connect(_on_life_change)
func _on_life_change(new_life: int) -> void:
	value = new_life
