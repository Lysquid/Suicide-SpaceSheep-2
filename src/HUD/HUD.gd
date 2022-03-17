extends CanvasLayer

var player

func init(_world, _player):
	player = get_parent().get_node("World/Player")
	_on_Player_score_changed()

func _ready() -> void:
	$HBoxContainer.visible = false
	set_process(false)
	
func _process(_delta: float) -> void:
	$HBoxContainer/Energy/Value.text = str(player.energy)

func _on_Menu_start() -> void:
	set_process(true)
	$HBoxContainer.visible = true
	$AnimationPlayer.play("Show")

func _on_Player_died() -> void:
	set_process(true)
	$AnimationPlayer.play("Hide")

func _on_Player_low_energy() -> void:
	$HBoxContainer/Energy/AnimationPlayer.play("LowEnergy")

func _on_Player_score_changed() -> void:
	$HBoxContainer/Score/Value.text = str(player.score)
	if player.score % 10 == 0 and player.score != 0:
		$HBoxContainer/Score/AnimationPlayer.play("Milestone")
