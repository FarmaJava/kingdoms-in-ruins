extends CharacterBody2D

@export var speed: float = 200.0
@export var map_rect: Rect2 = Rect2(0, 0, 1000, 1000)
@export var margin: float = 16.0  # mitad del tamaño del jugador, aprox.

# Ataque
@export var fireball_scene: PackedScene

# Vida
@export var max_health: float = 100.0
@export var invulnerability_time: float = 0.5

var health: float
var invulnerable_timer: float = 0.0

@onready var camera: Camera2D = $Camera2D
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group("player")
	health = max_health

	camera.limit_left = int(map_rect.position.x)
	camera.limit_top = int(map_rect.position.y)
	camera.limit_right = int(map_rect.end.x)
	camera.limit_bottom = int(map_rect.end.y)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_shoot(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()

	global_position = global_position.clamp(
		map_rect.position + Vector2(margin, margin),
		map_rect.end - Vector2(margin, margin)
	)

	invulnerable_timer = max(invulnerable_timer - delta, 0.0)
	if invulnerable_timer == 0.0:
		_check_contact_damage()

# ---------- Ataque ----------

func _shoot(target_position: Vector2) -> void:
	var fireball := fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = global_position
	fireball.direction = global_position.direction_to(target_position)

# ---------- Vida ----------

func _check_contact_damage() -> void:
	for body in hurtbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			take_damage(body.contact_damage)
			return

func take_damage(amount: float) -> void:
	health -= amount
	invulnerable_timer = invulnerability_time
	print("Vida: ", health)

	# parpadeo rojo para ver el golpe
	$Sprite2D.modulate = Color.RED
	create_tween().tween_property($Sprite2D, "modulate", Color.WHITE, 0.3)

	if health <= 0:
		get_tree().reload_current_scene()  # provisorio, luego hacemos un game over
