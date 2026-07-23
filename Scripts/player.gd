extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = 380.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float

func _process(delta):
	animate()
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	if velocity.x < 0:
		$Sprite2D.flip_h = true
		
func animate():
	if velocity.y > 0 and not is_on_floor():
		animation.play("Fall")
		return
	if velocity.y < 0 and not is_on_floor():
		animation.play("Jump")
		return
	if velocity.x != 0:
		animation.play("Run")
		return
	if velocity.x == 0:
		animation.play("Idle")
		return

func _physics_process(delta: float) -> void:
	gravidade(delta)
	mover()
	
func _input(event: InputEvent):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()
	direction = Input.get_axis("ui_left", "ui_right")
	
func mover():
		velocity.x = direction * speed
		move_and_slide()
	
func gravidade(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func jump():
	velocity.y = -jump_velocity
		
		
		
