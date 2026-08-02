extends CharacterBody2D

const SPEED = 400.0

@onready var animation: AnimationPlayer = $Animation
@onready var ray: RayCast2D = $Ray


@export var direction := -10

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if ray.is_colliding():
		direction *= -1
		ray.scale.x *= -1
		flip()

	if direction:
		velocity.x = direction * SPEED * delta

	move_and_slide()


func flip():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	if velocity.x < 0:
		$Sprite2D.flip_h = true
