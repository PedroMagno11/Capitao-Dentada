extends CharacterBody3D

@export var aceleracao: float = 5.0
@export var frenagem: float = 7.0
@export var velocidade_giro: float = 1.8
@export var velocidade_max: float = 8.0 #voou

## REMO
@export_category("Animação dos remos")
@export var amplitude_remada: float = 20.0
@export var velocidade_remada: float = 5.0

@onready var no_remos: Node3D = get_node(
	"BoteDentada/boat-row-large/paddles"
)

var velocidade_atual: float = 0.0
var fase_remada: float = 0.0
var rotacao_inicial_remos: Vector3

## MAR
@export_category("Balanço do mar")
@export var altura_balanco: float = 0.12
@export var inclinacao_balanco: float = 2.0
@export var velocidade_balanco: float = 1.5

@onready var visual_bote: Node3D = get_node("BoteDentada")

var tempo_balanco: float = 0.0
var posicao_inicial_bote: Vector3
var rotacao_inicial_bote: Vector3

## EFEITO FIIUUU
@export_category("Introdução da câmera")
@export var duracao_intro_camera: float = 3.0
@export var altura_camera_intro: float = 25.0
@export var recuo_camera_intro: float = -14.0

@onready var camera_principal: Camera3D = get_node("CameraPrincipal")

var introducao_ativa: bool = true
var transform_final_camera: Transform3D

func _ready() -> void:
	rotacao_inicial_remos = no_remos.rotation_degrees
	posicao_inicial_bote = visual_bote.position
	rotacao_inicial_bote = visual_bote.rotation_degrees
	
	transform_final_camera = camera_principal.transform

	camera_principal.position = Vector3(
		0.0,
		altura_camera_intro,
		recuo_camera_intro
	)

	camera_principal.look_at(
		global_position,
		Vector3.UP
	)
	
	iniciar_intro_camera()

func _physics_process(delta: float) -> void:
	
	## FIU
	if introducao_ativa:
		velocity = Vector3.ZERO
		animar_balanco_mar(delta)
		return
	
	var acelerador: float = Input.get_axis("frear", "acelerar")

	if acelerador != 0.0:
		velocidade_atual = move_toward(
			velocidade_atual,
			acelerador * velocidade_max,
			aceleracao * delta
		)
	else:
		velocidade_atual = move_toward(
			velocidade_atual,
			0.0,
			frenagem * delta
		)

	var giro: float = Input.get_axis(
		"virar_direita",
		"virar_esquerda"
	)

	rotate_y(giro * velocidade_giro * delta)

	var frente: Vector3 = global_transform.basis.z.normalized()

	velocity = frente * velocidade_atual
	velocity.y = 0.0

	move_and_slide()
	animar_remos(delta, giro)
	animar_balanco_mar(delta)

func animar_remos(delta: float, giro: float) -> void:
	
	var intensidade_movimento: float = clampf(
		absf(velocidade_atual) / velocidade_max,
		0.0,
		1.0
	)
	
	#var intensidade_giro: float = absf(giro)
	var intensidade_giro: float = absf(giro) * 0.5 #mais lentinha
	
	var intensidade: float = maxf(
		intensidade_movimento,
		intensidade_giro
	)

	if intensidade > 0.05:
		fase_remada += delta * velocidade_remada

		var nova_rotacao: Vector3 = rotacao_inicial_remos

		nova_rotacao.y += (
			sin(fase_remada)
			* amplitude_remada
			* intensidade
		)

		no_remos.rotation_degrees = nova_rotacao
	else:
		var suavizacao: float = minf(1.0, 8.0 * delta)

		no_remos.rotation_degrees = no_remos.rotation_degrees.lerp(
			rotacao_inicial_remos,
			suavizacao
		)

func animar_balanco_mar(delta: float) -> void:
	tempo_balanco += delta * velocidade_balanco

	var nova_posicao: Vector3 = posicao_inicial_bote
	nova_posicao.y += sin(tempo_balanco) * altura_balanco

	visual_bote.position = nova_posicao

	var nova_rotacao: Vector3 = rotacao_inicial_bote

	nova_rotacao.x += (
		sin(tempo_balanco * 0.8)
		* inclinacao_balanco
	)

	nova_rotacao.z += (
		sin(tempo_balanco * 0.55 + 1.2)
		* inclinacao_balanco
		* 0.7
	)

	visual_bote.rotation_degrees = nova_rotacao
	

func iniciar_intro_camera() -> void:
	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		camera_principal,
		"transform",
		transform_final_camera,
		duracao_intro_camera
	)

	tween.tween_callback(finalizar_intro_camera)

func finalizar_intro_camera() -> void:
	introducao_ativa = false
