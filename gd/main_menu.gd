extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var Credits_button: Button = $VBoxContainer/CreditsButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	Credits_button.pressed.connect(_on_credits_pressed)
	

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://tcsn/main.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://tcsn/settings.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://tcsn/creditos.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
