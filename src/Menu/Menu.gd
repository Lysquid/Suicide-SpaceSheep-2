extends CanvasLayer

signal start

onready var player = get_node("../World/Player")

func _ready() -> void:
	$CenterContainer/VBoxContainer/Score.hide()
	$CenterContainer/VBoxContainer/HighScore.hide()

func _on_PlayButton_pressed() -> void:
	$CenterContainer/VBoxContainer/PlayButton.disabled = true
	$AnimationPlayer.play("Hide")
	emit_signal("start")


func _on_Player_died() -> void:
	$CenterContainer/VBoxContainer/Score/Value.text = str(player.score)
	$CenterContainer/VBoxContainer/HighScore/Value.text = str(player.high_score)	

	$AnimationPlayer.play("Show")
	$CenterContainer/VBoxContainer/PlayButton.disabled = false

	$CenterContainer/VBoxContainer/Score.show()
	$CenterContainer/VBoxContainer/HighScore.show()


func _on_Player_new_high_score() -> void:
	$CenterContainer/VBoxContainer/HighScore.modulate = Color(1, 0.2, 0.2)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Hide":
			$CenterContainer/VBoxContainer/HighScore.modulate = Color(1, 1, 1)
			

