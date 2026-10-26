extends Area2D

@export var speed: float = 400.0
@export var max_range: float = 500.0

var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0

var traveled_distance: float = 0.0
var is_exploding: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animated_sprite.play("fly")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if is_exploding:
		return

	rotation = direction.angle()
	var step: Vector2 = direction * speed * delta
	global_position += step
	traveled_distance += step.length()

	if traveled_distance >= max_range:
		_explode()

func _on_body_entered(body: Node2D) -> void:
	if is_exploding:
		return

	if body.is_in_group("enemies"):
		body.take_damage(damage)
		_explode()
	elif body.is_in_group("obstacles"):
		_explode()

func _explode() -> void:
	is_exploding = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("impact")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "impact":
		queue_free()
