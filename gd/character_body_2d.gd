extends CharacterBody2D

signal health_changed(current: float, max_hp: float)
signal mana_changed(current: float, max_mp: float)
signal xp_changed(current: float, needed: float, player_level: int)
signal skills_changed(levels: Dictionary, points: int)
signal died

@export var map_rect: Rect2 = Rect2(0, 0, 3000, 3000)
@export var margin: float = 16.0  # mitad del tamaño del jugador, aprox.

# Ataque
@export var fireball_scene: PackedScene
@export var base_damage: float = 12.0
@export var damage_per_level: float = 10.0
@export var fireball_mana_cost: float = 20.0
@export var base_fireball_range: float = 500.0

# Velocidad
@export var base_speed: float = 200.0
@export var speed_per_level: float = 12.0

# Vida
@export var base_max_health: float = 100.0
@export var health_per_level: float = 15.0
@export var invulnerability_time: float = 0.5

# Maná
@export var base_max_mana: float = 50.0
@export var mana_per_level: float = 12.0
@export var base_mana_regen: float = 8.0
@export var mana_regen_per_level: float = 1.5

# Level up
@export var level_up_invulnerable_time: float = 0.5

var speed: float
var max_health: float
var health: float
var max_mana: float
var mana: float
var mana_regen: float
var fireball_range: float

var invulnerable_timer: float = 0.0
var is_leveling_up: bool = false
var is_dead: bool = false

# Estadísticas de la partida
var survival_time: float = 0.0
var kills: int = 0

var xp: float = 0.0
var xp_to_next: float = 50.0
var player_level: int = 1
var skill_points: int = 0

var skill_levels := {
	"damage": 1,
	"speed": 1,
	"health": 1,
	"mana": 1,
}

@onready var camera: Camera2D = $Camera2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

	speed = base_speed
	max_health = base_max_health
	health = max_health
	max_mana = base_max_mana
	mana = max_mana
	mana_regen = base_mana_regen
	fireball_range = base_fireball_range

	camera.limit_left = int(map_rect.position.x)
	camera.limit_top = int(map_rect.position.y)
	camera.limit_right = int(map_rect.end.x)
	camera.limit_bottom = int(map_rect.end.y)

	health_changed.emit(health, max_health)
	mana_changed.emit(mana, max_mana)
	xp_changed.emit(xp, xp_to_next, player_level)
	skills_changed.emit(skill_levels, skill_points)

func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_shoot(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	survival_time += delta

	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_update_animation(dir)

	global_position = global_position.clamp(
		map_rect.position + Vector2(margin, margin),
		map_rect.end - Vector2(margin, margin)
	)

	mana = min(mana + mana_regen * delta, max_mana)
	mana_changed.emit(mana, max_mana)

	invulnerable_timer = max(invulnerable_timer - delta, 0.0)
	if invulnerable_timer == 0.0:
		_check_contact_damage()

# ---------- Utilidades ----------

func get_time_text() -> String:
	var minutes := floori(survival_time / 60.0)
	var seconds := int(survival_time) % 60
	return "%02d:%02d" % [minutes, seconds]

# ---------- Animación ----------

func _update_animation(dir: Vector2) -> void:
	if is_leveling_up:
		return

	if dir == Vector2.ZERO:
		animated_sprite.pause()
		return

	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		animated_sprite.play("walk_down" if dir.y > 0 else "walk_up")

func _play_level_up_animation() -> void:
	is_leveling_up = true
	invulnerable_timer = max(invulnerable_timer, level_up_invulnerable_time)
	animated_sprite.play("level_up")
	get_tree().create_timer(level_up_invulnerable_time).timeout.connect(_end_level_up, CONNECT_ONE_SHOT)

func _end_level_up() -> void:
	is_leveling_up = false

# ---------- Ataque ----------

func _shoot(target_position: Vector2) -> void:
	if mana < fireball_mana_cost:
		return

	mana -= fireball_mana_cost
	mana_changed.emit(mana, max_mana)

	var damage: float = base_damage + (skill_levels["damage"] - 1) * damage_per_level

	var fireball := fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = global_position
	fireball.direction = global_position.direction_to(target_position)
	fireball.damage = damage
	fireball.max_range = fireball_range

# ---------- Vida ----------

func _check_contact_damage() -> void:
	for body in hurtbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			take_damage(body.contact_damage)
			return

func take_damage(amount: float) -> void:
	if is_dead:
		return

	health -= amount
	invulnerable_timer = invulnerability_time
	health_changed.emit(health, max_health)

	animated_sprite.modulate = Color.RED
	create_tween().tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)

	if health <= 0:
		is_dead = true
		died.emit()

func increase_max_health(amount: float) -> void:
	max_health += amount
	health += amount
	health_changed.emit(health, max_health)

# ---------- Experiencia y habilidades ----------

func add_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		player_level += 1
		skill_points += 1
		xp_to_next *= 1.2
		fireball_range *= 1.15
	xp_changed.emit(xp, xp_to_next, player_level)
	skills_changed.emit(skill_levels, skill_points)

func level_up_skill(skill_name: String) -> void:
	if skill_points <= 0 or not skill_levels.has(skill_name):
		return

	skill_points -= 1
	skill_levels[skill_name] += 1

	match skill_name:
		"speed":
			speed = base_speed + (skill_levels["speed"] - 1) * speed_per_level
		"health":
			var old_max := max_health
			max_health = base_max_health + (skill_levels["health"] - 1) * health_per_level
			health += (max_health - old_max)
			health_changed.emit(health, max_health)
		"mana":
			var old_max_mana := max_mana
			max_mana = base_max_mana + (skill_levels["mana"] - 1) * mana_per_level
			mana_regen = base_mana_regen + (skill_levels["mana"] - 1) * mana_regen_per_level
			mana += (max_mana - old_max_mana)
			mana_changed.emit(mana, max_mana)
		"damage":
			pass

	skills_changed.emit(skill_levels, skill_points)
	_play_level_up_animation()
