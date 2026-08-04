extends AnimatedSprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Cenas/naval_3d/travessia_03.tscn")
