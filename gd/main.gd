extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_distance: float = 700.0  # un poco más que la mitad de tu pantalla

@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_enemy)

func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = _get_spawn_position()

func _get_spawn_position() -> Vector2:
	var pos := Vector2.ZERO
	for i in 10:
		pos = player.global_position + Vector2.from_angle(randf() * TAU) * spawn_distance
		if player.map_rect.has_point(pos):
			return pos
	return pos.clamp(player.map_rect.position, player.map_rect.end)
