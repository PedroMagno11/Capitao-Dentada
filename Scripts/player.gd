extends CharacterBody2D


@export var speed = 200.0
@export var jump_velocity = 380.0
@export var vida_max = 10
@export var dano = 2

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var timer: Timer = $Timer
@onready var barra_de_vida: ProgressBar = $ProgressBar
@onready var hud: Label = $"../Hud/Moeda"


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float
var atacando: bool 
var vida: int = vida_max
var is_dead: bool = false
var levando_hit: bool = false
var contador_de_moeda: int = 0

const ATTACK_POSITION_COLLISION_RIGHT = 109
const ATTACK_POSITION_COLLISION_LEFT = 74


func _ready() -> void:
	barra_de_vida.max_value = vida_max
	barra_de_vida.value = vida

func _process(delta):
	if is_dead:
		return
	animate()
	mudarADirecaoDoPersonagem()
	
func mudarADirecaoDoPersonagem():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
		$AttackArea/Collision.position.x = ATTACK_POSITION_COLLISION_RIGHT
	if velocity.x < 0:
		$Sprite2D.flip_h = true
		$AttackArea/Collision.position.x = ATTACK_POSITION_COLLISION_LEFT

func animate():
	if is_dead:
		animation.play("Dead Ground")
		return
	if levando_hit:
		animation.play("Hit")
		return
	if atacando:
		animation.play("ataque")
		return
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
	if is_dead:
		return
	gravidade(delta)
	mover()
	
func _input(event: InputEvent):
	if is_dead:
		return
		
	if Input.is_action_just_pressed("pular") and is_on_floor():
		jump()
	if Input.is_action_pressed("atacar"):
		atacar()

	direction = Input.get_axis("esquerda", "direita")
	
func mover():
		velocity.x = direction * speed
		move_and_slide()
	
func gravidade(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func jump():
	velocity.y = -jump_velocity
		
func atacar():
	atacando = true
		
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ataque":
		atacando = false		
	if anim_name == "Dead Ground":
		timer.start()
	if anim_name == "Hit":
		levando_hit = false
		
func take_damage(amout: int):
	if is_dead:
		return
	
	vida -= amout
	barra_de_vida.value = vida

	if vida <= 0:
		die()
	else:
		levando_hit = true
		animation.play("Hit")
		
func die():
	is_dead = true
	animation.play("Dead Ground")
	velocity = Vector2.ZERO


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo") and atacando:
		body.take_damage(dano)

func coletar_moeda():
	contador_de_moeda += 1
	hud.text = "Moedas: %d" %contador_de_moeda
