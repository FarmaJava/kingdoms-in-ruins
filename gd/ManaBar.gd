extends TextureProgressBar

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.mana_changed.connect(_on_mana_changed)
		_on_mana_changed(player.mana, player.max_mana)

func _on_mana_changed(current: float, max_mp: float) -> void:
	max_value = max_mp
	value = current
