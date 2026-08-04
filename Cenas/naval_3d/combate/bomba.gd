extends Area3D

## É BOMBA ##

@export_category("Movimento")
@export var velocidade_horizontal: float = 16.0
@export var impulso_vertical: float = 7.0
@export var gravidade: float = 15.0
@export var tempo_de_vida: float = 5.0

@export_category("Combate")
@export var dano: int = 25

var direcao: Vector3 = Vector3.ZERO
var velocidade_vertical: float = 0.0

var grupo_alvo: StringName = &"inimigos"
var corpo_que_disparou: Node3D

func _ready() -> void:
	body_entered.connect(_ao_atingir_corpo)

	get_tree().create_timer(tempo_de_vida).timeout.connect(
		queue_free
	)

func configurar(
	nova_direcao: Vector3,
	novo_grupo_alvo: StringName,
	novo_atirador: Node3D
) -> void:
	direcao = Vector3(
		nova_direcao.x,
		0.0,
		nova_direcao.z
	).normalized()

	grupo_alvo = novo_grupo_alvo
	corpo_que_disparou = novo_atirador
	velocidade_vertical = impulso_vertical


func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade_horizontal * delta

	velocidade_vertical -= gravidade * delta
	global_position.y += velocidade_vertical * delta

	rotate_x(4.0 * delta)

func _ao_atingir_corpo(corpo: Node3D) -> void:
	if corpo == corpo_que_disparou:
		return

	if corpo.is_in_group(grupo_alvo):
		if corpo.has_method("receber_dano"):
			corpo.receber_dano(dano)

		queue_free()
		return

	if corpo is StaticBody3D:
		queue_free()
