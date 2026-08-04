extends Area3D


@export_file("*.tscn")
var cena_destino: String = ""

var trocando_cena: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if trocando_cena:
		return

	if not body.is_in_group(&"jogador"):
		return

	if cena_destino.is_empty():
		push_warning(
			"Nenhuma cena 2D foi configurada para este porto."
		)
		return

	if not ResourceLoader.exists(cena_destino):
		push_error(
			"A cena configurada para o porto não existe: ",
			cena_destino
		)
		return

## Portinha
## É só definir "Cena Destino" no inspetor
	trocando_cena = true
	get_tree().paused = false
	get_tree().change_scene_to_file(cena_destino)
