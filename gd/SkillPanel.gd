extends Control

@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel
@onready var points_label: Label = $PointsLabel

@onready var damage_level_label: Label = $HBoxContainer/DamageSkill/LevelValueLabel
@onready var speed_level_label: Label = $HBoxContainer/SpeedSkill/LevelValueLabel
@onready var health_level_label: Label = $HBoxContainer/HealthSkill/LevelValueLabel
@onready var mana_level_label: Label = $HBoxContainer/ManaSkill/LevelValueLabel

@onready var damage_button: Button = $HBoxContainer/DamageSkill/PlusButton
@onready var speed_button: Button = $HBoxContainer/SpeedSkill/PlusButton
@onready var health_button: Button = $HBoxContainer/HealthSkill/PlusButton
@onready var mana_button: Button = $HBoxContainer/ManaSkill/PlusButton

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	player.xp_changed.connect(_on_xp_changed)
	player.skills_changed.connect(_on_skills_changed)

	damage_button.pressed.connect(func(): player.level_up_skill("damage"))
	speed_button.pressed.connect(func(): player.level_up_skill("speed"))
	health_button.pressed.connect(func(): player.level_up_skill("health"))
	mana_button.pressed.connect(func(): player.level_up_skill("mana"))

	_on_xp_changed(player.xp, player.xp_to_next, player.player_level)
	_on_skills_changed(player.skill_levels, player.skill_points)

func _on_xp_changed(current: float, needed: float, level: int) -> void:
	xp_bar.max_value = needed
	xp_bar.value = current
	level_label.text = "Nivel %d" % level

func _on_skills_changed(levels: Dictionary, points: int) -> void:
	points_label.text = "PM: %d" % points
	damage_level_label.text = "Nv. %d" % levels["damage"]
	speed_level_label.text = "Nv. %d" % levels["speed"]
	health_level_label.text = "Nv. %d" % levels["health"]
	mana_level_label.text = "Nv. %d" % levels["mana"]

	damage_button.disabled = points <= 0
	speed_button.disabled = points <= 0
	health_button.disabled = points <= 0
	mana_button.disabled = points <= 0
