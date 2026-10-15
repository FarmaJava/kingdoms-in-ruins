extends TextureProgressBar

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, player.max_health)

func _on_health_changed(current: float, max_hp: float) -> void:
	max_value = max_hp
	value = current
