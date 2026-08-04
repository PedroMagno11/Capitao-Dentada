extends CanvasLayer

## GERAL TRAVESSIAS

@export_category("Animação")
@export var tempo_exibicao_titulo: float = 3.0
@export var duracao_fade: float = 0.8

@onready var titulo_travessia: Label = $TituloTravessia
@onready var fundo_titulo: TextureRect = $FundoTitulo
@onready var conteudo_hud: Control = $ConteudoHUD
@onready var tela_game_over: Control = $TelaGameOver
@onready var tela_instrucoes: Control = $TelaInstrucoes

@onready var barra_vida_jogador: TextureProgressBar = (
	$ConteudoHUD/VidaJogador/Preenchimento
)

@onready var painel_vida_jogador: Control = (
	$ConteudoHUD/VidaJogador
)

@onready var painel_vida_inimigo: Control = (
	$ConteudoHUD/VidaInimigo
)

@onready var barra_vida_inimigo: TextureProgressBar = (
	$ConteudoHUD/VidaInimigo/Preenchimento
)

var inimigo_ativo: Node3D = null
var jogo_encerrado: bool = false

func _ready() -> void:
	# HUD funciona enquanto o jogo está pausado - Para de tomar dado
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	titulo_travessia.modulate.a = 1.0
	fundo_titulo.modulate.a = 1.0
	conteudo_hud.modulate.a = 0.0

	# segura os fiu e o nome da travessia
	titulo_travessia.hide()
	fundo_titulo.hide()
	conteudo_hud.hide()

	painel_vida_inimigo.hide()
	tela_game_over.hide()
	tela_instrucoes.show()

	call_deferred("conectar_sistemas_de_vida")

func iniciar_animacao_hud() -> void:
	var tween: Tween = create_tween()

	tween.tween_interval(
		tempo_exibicao_titulo
	)

	tween.tween_property(
		titulo_travessia,
		"modulate:a",
		0.0,
		duracao_fade
	)

	tween.parallel().tween_property(
		fundo_titulo,
		"modulate:a",
		0.0,
		duracao_fade
	)

	tween.parallel().tween_property(
		conteudo_hud,
		"modulate:a",
		1.0,
		duracao_fade
	)

	tween.tween_callback(
		finalizar_titulo
	)

func finalizar_titulo() -> void:
	titulo_travessia.hide()
	fundo_titulo.hide()

func conectar_sistemas_de_vida() -> void:
	conectar_vida_jogador()
	conectar_inimigos()

func conectar_vida_jogador() -> void:
	var jogador: Node = get_tree().get_first_node_in_group(
		&"jogador"
	)

	if jogador == null:
		push_warning(
			"O HUD não encontrou a embarcação no grupo 'jogador'."
		)
		painel_vida_jogador.hide()
		return

	# o bote ainda não tem vida (t1)
	if not jogador.has_signal(&"vida_alterada"):
		painel_vida_jogador.hide()
		return

	var vida_atual_jogador = jogador.get("vida_atual")
	var vida_maxima_jogador = jogador.get("vida_maxima")

	if vida_atual_jogador == null or vida_maxima_jogador == null:
		painel_vida_jogador.hide()
		return

	painel_vida_jogador.show()

	conectar_sinal(
		jogador,
		&"vida_alterada",
		Callable(self, "atualizar_vida_jogador")
	)

	if jogador.has_signal(&"jogador_destruido"):
		conectar_sinal(
			jogador,
			&"jogador_destruido",
			Callable(self, "mostrar_game_over")
		)

	atualizar_vida_jogador(
		int(vida_atual_jogador),
		int(vida_maxima_jogador)
	)


func conectar_inimigos() -> void:
	var inimigos: Array[Node] = get_tree().get_nodes_in_group(
		&"inimigos"
	)

	for inimigo: Node in inimigos:
		conectar_sinal(
			inimigo,
			&"combate_iniciado",
			Callable(self, "ao_combate_iniciado")
		)

		conectar_sinal(
			inimigo,
			&"combate_encerrado",
			Callable(self, "ao_combate_encerrado")
		)

		conectar_sinal(
			inimigo,
			&"vida_alterada",
			Callable(self, "atualizar_vida_inimigo")
		)

		conectar_sinal(
			inimigo,
			&"inimigo_destruido",
			Callable(self, "ao_inimigo_destruido")
		)


func conectar_sinal(
	emissor: Node,
	nome_sinal: StringName,
	destino: Callable
) -> void:
	if not emissor.has_signal(nome_sinal):
		return

	if not emissor.is_connected(
		nome_sinal,
		destino
	):
		emissor.connect(
			nome_sinal,
			destino
		)


func atualizar_vida_jogador(
	vida_atual: int,
	vida_maxima: int
) -> void:
	barra_vida_jogador.min_value = 0
	barra_vida_jogador.max_value = vida_maxima
	barra_vida_jogador.value = vida_atual


func ao_combate_iniciado(
	inimigo: Node3D
) -> void:
	if jogo_encerrado:
		return

	inimigo_ativo = inimigo
	painel_vida_inimigo.show()

	atualizar_vida_inimigo(
		inimigo,
		int(inimigo.get("vida_atual")),
		int(inimigo.get("vida_maxima"))
	)


func atualizar_vida_inimigo(
	inimigo: Node3D,
	vida_atual: int,
	vida_maxima: int
) -> void:
	if inimigo != inimigo_ativo:
		return

	barra_vida_inimigo.min_value = 0
	barra_vida_inimigo.max_value = vida_maxima
	barra_vida_inimigo.value = vida_atual


func ao_combate_encerrado(
	inimigo: Node3D
) -> void:
	if inimigo != inimigo_ativo:
		return

	inimigo_ativo = null
	painel_vida_inimigo.hide()


func ao_inimigo_destruido(
	inimigo: Node3D
) -> void:
	if inimigo != inimigo_ativo:
		return

	barra_vida_inimigo.value = 0

	inimigo_ativo = null
	painel_vida_inimigo.hide()


func mostrar_game_over() -> void:
	if jogo_encerrado:
		return

	jogo_encerrado = true

	titulo_travessia.hide()
	fundo_titulo.hide()
	conteudo_hud.hide()
	painel_vida_inimigo.hide()
	tela_instrucoes.hide()

	tela_game_over.show()
	get_tree().paused = true


func _on_botao_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_botao_entendido_pressed() -> void:
	tela_instrucoes.hide()

	titulo_travessia.show()
	fundo_titulo.show()
	conteudo_hud.show()

	get_tree().paused = false
	iniciar_animacao_hud()
