extends CharacterBody3D

@export var aceleracao: float = 5.0
@export var frenagem: float = 7.0
@export var velocidade_giro: float = 1.8
@export var velocidade_max: float = 8.0 #voou

@export_category("Animação dos remos")
@export var amplitude_remada: float = 20.0
@export var velocidade_remada: float = 5.0

@onready var no_remos: Node3D = get_node(
	"BoteDentada/boat-row-large/paddles"
)

var velocidade_atual: float = 0.0
var fase_remada: float = 0.0
var rotacao_inicial_remos: Vector3


func _ready() -> void:
	rotacao_inicial_remos = no_remos.rotation_degrees


func _physics_process(delta: float) -> void:
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
