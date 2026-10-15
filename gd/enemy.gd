extends CharacterBody2D

@export var speed: float = 60.0
@export var contact_damage: float = 10.0
@export var max_health: float = 30.0

var health: float
var player: Node2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var dir := global_position.direction_to(player.global_position)
	velocity = dir * speed
	move_and_slide()
	_update_animation(dir)

func _update_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		animated_sprite.play("walk_down" if dir.y > 0 else "walk_up")

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()
