extends CharacterBody3D


signal vida_alterada(
	inimigo: Node3D,
	vida_atual: int,
	vida_maxima: int
)

signal combate_iniciado(inimigo: Node3D)
signal combate_encerrado(inimigo: Node3D)
signal inimigo_destruido(inimigo: Node3D)

## VIDA
@export_category("Vida")
@export var vida_maxima: int = 100

var vida_atual: int

## MOVIMENTO
@export_category("Movimento")

# Velocidade de avanço e recuo do inimigo.
@export var velocidade_movimento: float = 4.0

# Velocidade com que ele gira em direção ao jogador.
@export var velocidade_giro: float = 1.5

# Acima desta distância, o inimigo tenta se aproximar.
@export var distancia_ideal: float = 20.0

# Abaixo desta distância, o inimigo recua.
@export var distancia_minima: float = 12.0

## COMBATE
@export_category("Combate")
@export var cena_bomba: PackedScene
@export var saida_bomba: Marker3D

@export var intervalo_tiro: float = 3.0

# Ao entrar nesta distância, o inimigo:
# - começa a perseguir
# - começa a atirar
# - mostra sua barra de vida
@export var alcance_ativacao: float = 35.0


var jogador: Node3D
var tempo_ate_proximo_tiro: float = 0.0
var em_combate: bool = false


func _ready() -> void:
	vida_atual = vida_maxima

	jogador = get_tree().get_first_node_in_group(
		&"jogador"
	) as Node3D

	tempo_ate_proximo_tiro = intervalo_tiro


func _physics_process(delta: float) -> void:
	# Tenta localizar o jogador novamente caso ele ainda não existisse.
	if not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group(
			&"jogador"
		) as Node3D

		velocity = Vector3.ZERO
		return

	var direcao_jogador: Vector3 = (
		jogador.global_position
		- global_position
	)

	# O navio se move somente no plano horizontal.
	direcao_jogador.y = 0.0

	var distancia: float = direcao_jogador.length()

	# Fora da distância de ativação:
	# não persegue, não atira e esconde a barra
	if distancia > alcance_ativacao:
		velocity = Vector3.ZERO
		encerrar_combate()
		return

	# Dentro da distância de ativação.
	iniciar_combate()

	tempo_ate_proximo_tiro -= delta

	# Gira o navio em direção ao jogador.
	if direcao_jogador.length_squared() > 0.001:
		direcao_jogador = direcao_jogador.normalized()

		var rotacao_desejada: float = atan2(
			direcao_jogador.x,
			direcao_jogador.z
		)

		rotation.y = lerp_angle(
			rotation.y,
			rotacao_desejada,
			velocidade_giro * delta
		)

	var frente: Vector3 = (
		global_transform.basis.z.normalized()
	)

	# Está longe da distância ideal: aproxima-se.
	if distancia > distancia_ideal:
		velocity = frente * velocidade_movimento

	# Está perto demais: recua.
	elif distancia < distancia_minima:
		velocity = -frente * velocidade_movimento

	# Está em uma distância adequada: permanece parado.
	else:
		velocity = Vector3.ZERO

	velocity.y = 0.0

	move_and_slide()

	# Atira enquanto estiver dentro da área de ativação.
	if tempo_ate_proximo_tiro <= 0.0:
		disparar_bomba()
		tempo_ate_proximo_tiro = intervalo_tiro

func iniciar_combate() -> void:
	if em_combate:
		return

	em_combate = true

	combate_iniciado.emit(self)

	# Atualiza a barra assim que ela aparecer.
	vida_alterada.emit(
		self,
		vida_atual,
		vida_maxima
	)

func encerrar_combate() -> void:
	if not em_combate:
		return

	em_combate = false
	combate_encerrado.emit(self)


func receber_dano(dano: int) -> void:
	vida_atual = maxi(
		vida_atual - dano,
		0
	)

	vida_alterada.emit(
		self,
		vida_atual,
		vida_maxima
	)

	print(
		"Navio inimigo recebeu ",
		dano,
		" de dano. Vida restante: ",
		vida_atual
	)

	if vida_atual <= 0:
		destruir()


func destruir() -> void:
	print("Navio inimigo destruído!")

	inimigo_destruido.emit(self)

	if em_combate:
		em_combate = false
		combate_encerrado.emit(self)

	queue_free()


func disparar_bomba() -> void:
	if cena_bomba == null:
		push_warning(
			"A cena da bomba do inimigo não foi configurada."
		)
		return

	if saida_bomba == null:
		push_warning(
			"A saída da bomba do inimigo não foi configurada."
		)
		return

	if not is_instance_valid(jogador):
		return

	var bomba = cena_bomba.instantiate()

	get_tree().current_scene.add_child(bomba)

	bomba.global_position = saida_bomba.global_position

	var direcao_disparo: Vector3 = (
		jogador.global_position
		- saida_bomba.global_position
	).normalized()

	bomba.configurar(
		direcao_disparo,
		&"jogador",
		self
	)
