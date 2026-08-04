extends CharacterBody3D

## dentada full

signal vida_alterada(vida_atual: int, vida_maxima: int)
signal jogador_destruido


## MOVIMENTO
@export_category("Movimento")
@export var aceleracao: float = 5.0
@export var frenagem: float = 7.0
@export var velocidade_giro: float = 1.8
@export var velocidade_max: float = 8.0

var velocidade_atual: float = 0.0


## VIDA
@export_category("Vida")
@export var vida_maxima: int = 100

var vida_atual: int


## COMBATE
@export_category("Combate")
@export var cena_bomba: PackedScene
@export var saida_bomba_direita: Marker3D


## BALANÇO DO MAR
@export_category("Balanço do mar")
@export var altura_balanco: float = 0.12
@export var inclinacao_balanco: float = 2.0
@export var velocidade_balanco: float = 1.5

@onready var visual_navio: Node3D = (
	$NavioGrandeDentada
)

@onready var vela_a: Node3D = get_node(
	"NavioGrandeDentada/ship-pirate-large/sail-a"
)

@onready var vela_b: Node3D = get_node(
	"NavioGrandeDentada/ship-pirate-large/sail-b"
)

var rotacao_inicial_vela_a: Vector3
var rotacao_inicial_vela_b: Vector3

var tempo_balanco: float = 0.0
var posicao_inicial_navio: Vector3
var rotacao_inicial_navio: Vector3


## INTRODUÇÃO DA CÂMERA
@export_category("Introdução da câmera")
@export var duracao_intro_camera: float = 4.0

# Posição inicial: na frente do navio.
@export var altura_camera_frontal: float = 5.0
@export var distancia_camera_frontal: float = 12.0

# Altura máxima do arco. - movi cam
@export var altura_arco_camera: float = 16.0

# Altura do ponto para o qual a câmera olha.
@export var altura_alvo_camera: float = 2.5

@onready var camera_principal: Camera3D = (
	$CameraPrincipal
)

var introducao_ativa: bool = true
var transform_final_camera: Transform3D

var ponto_inicio_camera: Vector3
var ponto_meio_camera: Vector3
var ponto_final_camera: Vector3


func _ready() -> void:
	vida_atual = vida_maxima

	vida_alterada.emit(
		vida_atual,
		vida_maxima
	)

	posicao_inicial_navio = visual_navio.position
	rotacao_inicial_navio = visual_navio.rotation_degrees

	rotacao_inicial_vela_a = vela_a.rotation_degrees
	rotacao_inicial_vela_b = vela_b.rotation_degrees

	# Guarda a posição normal da câmera definida no editor.
	transform_final_camera = camera_principal.transform

	ponto_inicio_camera = Vector3(
		0.0,
		altura_camera_frontal,
		distancia_camera_frontal
	)

	ponto_meio_camera = Vector3(
		0.0,
		altura_arco_camera,
		0.0
	)

	ponto_final_camera = transform_final_camera.origin

	camera_principal.position = ponto_inicio_camera

	camera_principal.look_at(
		global_position + Vector3.UP * altura_alvo_camera,
		Vector3.UP
	)

	iniciar_intro_camera()

func _physics_process(delta: float) -> void:
	if introducao_ativa:
		velocity = Vector3.ZERO
		animar_balanco_mar(delta)
		animar_velas()
		return

	if Input.is_action_just_pressed("bomba"):
		disparar_bomba()

	var acelerador: float = Input.get_axis(
		"frear",
		"acelerar"
	)

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

	rotate_y(
		giro * velocidade_giro * delta
	)

	var frente: Vector3 = (
		global_transform.basis.z.normalized()
	)

	velocity = frente * velocidade_atual
	velocity.y = 0.0

	move_and_slide()

	animar_balanco_mar(delta)
	animar_velas()


func animar_balanco_mar(delta: float) -> void:
	tempo_balanco += delta * velocidade_balanco

	var nova_posicao: Vector3 = posicao_inicial_navio

	nova_posicao.y += (
		sin(tempo_balanco)
		* altura_balanco
	)

	visual_navio.position = nova_posicao

	var nova_rotacao: Vector3 = rotacao_inicial_navio

	nova_rotacao.x += (
		sin(tempo_balanco * 0.8)
		* inclinacao_balanco
	)

	nova_rotacao.z += (
		sin(tempo_balanco * 0.55 + 1.2)
		* inclinacao_balanco
		* 0.7
	)

	visual_navio.rotation_degrees = nova_rotacao


func iniciar_intro_camera() -> void:
	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		atualizar_intro_camera,
		0.0,
		1.0,
		duracao_intro_camera
	)

	tween.tween_callback(
		finalizar_intro_camera
	)


func atualizar_intro_camera(
	progresso: float
) -> void:
	var inverso: float = 1.0 - progresso

	# Curva de Bézier:
	# frente -> alto -> posição normal.
	camera_principal.position = (
		inverso * inverso * ponto_inicio_camera
		+ 2.0
		* inverso
		* progresso
		* ponto_meio_camera
		+ progresso
		* progresso
		* ponto_final_camera
	)

	camera_principal.look_at(
		global_position + Vector3.UP * altura_alvo_camera,
		Vector3.UP
	)


func finalizar_intro_camera() -> void:
	camera_principal.transform = transform_final_camera
	introducao_ativa = false


func animar_velas() -> void:
	var movimento_vento: float = sin(
		tempo_balanco * 2.5
	)

	var nova_rotacao_a: Vector3 = rotacao_inicial_vela_a
	var nova_rotacao_b: Vector3 = rotacao_inicial_vela_b

	nova_rotacao_a.y += movimento_vento * 2.0
	nova_rotacao_b.y += movimento_vento * 1.5

	vela_a.rotation_degrees = nova_rotacao_a
	vela_b.rotation_degrees = nova_rotacao_b


func disparar_bomba() -> void:
	if cena_bomba == null:
		push_warning(
			"A cena da bomba não foi configurada."
		)
		return

	if saida_bomba_direita == null:
		push_warning(
			"A saída da bomba não foi configurada."
		)
		return

	var bomba = cena_bomba.instantiate()

	# Coloca a bomba na travessia,
	# e não como filha do navio.
	get_tree().current_scene.add_child(
		bomba
	)

	# Faz a bomba nascer no Marker3D.
	bomba.global_position = (
		saida_bomba_direita.global_position
	)

	# Disparo pela lateral direita do navio.
	var direcao_disparo: Vector3 = (
		-saida_bomba_direita
		.global_transform
		.basis
		.x
		.normalized()
	)

	bomba.configurar(
		direcao_disparo,
		&"inimigos",
		self
	)

func receber_dano(dano: int) -> void:
	vida_atual = maxi(
		vida_atual - dano,
		0
	)

	vida_alterada.emit(
		vida_atual,
		vida_maxima
	)

	print(
		"Navio do jogador recebeu ",
		dano,
		" de dano. Vida restante: ",
		vida_atual
	)

	if vida_atual <= 0:
		destruir_jogador()


func destruir_jogador() -> void:
	print(
		"O navio do Capitão Dentada foi destruído!"
	)

	set_physics_process(false)
	velocity = Vector3.ZERO

	jogador_destruido.emit()
