extends StaticBody2D

@onready var timer: Timer = $Timer

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.is_in_group("player")
	get_tree().change_scene_to_file("res://Cenas/naval_3d/travessia_01.tscn")
	timer.start(2.0)


func _on_timer_timeout() -> void:
	queue_free()
