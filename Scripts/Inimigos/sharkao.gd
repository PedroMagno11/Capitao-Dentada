extends CharacterBody2D

const SPEED = 400.0
const VIDA_MAX = 10
const DANO = 1

@onready var animation: AnimationPlayer = $Animation
@onready var ray: RayCast2D = $Ray
@onready var collision: CollisionShape2D = $AttackArea/Collision


var atacando: bool
var vida: int = VIDA_MAX
var is_dead: bool = false
var levando_hit: bool = false

@export var direction := -10

func _physics_process(delta: float) -> void:
	if is_dead or levando_hit:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if ray.is_colliding():
		direction *= -1
		ray.scale.x *= -1
		flip()

	if direction and not atacando:
		velocity.x = direction * SPEED * delta
		animation.play("run")
		
		
	move_and_slide()


func flip():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	if velocity.x < 0:
		$Sprite2D.flip_h = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		atacando = true
		animation.play("attack")
		body.take_damage(DANO)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		atacando = false
		animation.play("run")


func _on_animation_finished(anim_name: StringName) -> void:
	if is_dead:
		queue_free()
		return
	if anim_name == "attack":
		if atacando:
			animation.play("attack")
		else:
			animation.play("run")
	elif anim_name == "hit":
		levando_hit = false
		if atacando:
			animation.play("attack")
		else: 
			animation.play("run")


func take_damage(amout: int):
	if is_dead:
		return
	
	vida -= amout
	if vida <= 0:
		die()
	else:
		levando_hit = true
		animation.play("hit")
		
		
func die():
	is_dead = true
	animation.play("dead_ground")
	velocity = Vector2.ZERO
