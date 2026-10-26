extends Control

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var kills_label: Label = $VBoxContainer/KillsLabel
@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

var player: Node2D

func _ready() -> void:
	# Necesario para que los botones funcionen con el juego pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	time_label.text = "Tiempo sobrevivido: %s" % player.get_time_text()
	kills_label.text = "Enemigos eliminados: %d" % player.kills
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://tcsn/main_menu.tscn")
