extends CharacterBody2D

@export var speed: float = 60.0
@export var contact_damage: float = 10.0
@export var max_health: float = 30.0
@export var attack_range: float = 40.0
@export var xp_value: float = 10.0

var health: float
var player: Node2D
var is_attacking: bool = false
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	animated_sprite.animation_finished.connect(_on_attack_finished)

func _physics_process(_delta: float) -> void:
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if distance <= attack_range:
		_start_attack()
		return

	var dir := global_position.direction_to(player.global_position)
	last_direction = dir
	velocity = dir * speed
	move_and_slide()
	_update_walk_animation(dir)

func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	_update_attack_animation(last_direction)
	get_tree().create_timer(0.6).timeout.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished() -> void:
	is_attacking = false

func _update_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("Right" if dir.x > 0 else "Left")
	else:
		animated_sprite.play("Down" if dir.y > 0 else "Up")

func _update_attack_animation(dir: Vector2) -> void:
	var anim_name: String
	if abs(dir.x) > abs(dir.y):
		anim_name = "attack_right" if dir.x > 0 else "attack_left"
	else:
		anim_name = "attack_down" if dir.y > 0 else "attack_up"

	animated_sprite.play(anim_name)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		if player:
			player.kills += 1
			player.add_xp(xp_value)
		queue_free()
