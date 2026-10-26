extends Control

@onready var time_label: Label = $TimeLabel
@onready var kills_label: Label = $KillsLabel

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if player == null:
		return
	time_label.text = player.get_time_text()
	kills_label.text = "Kills: %d" % player.kills
