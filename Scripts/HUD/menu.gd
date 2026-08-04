extends Node2D




func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/naval_3d/travessia_01.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
