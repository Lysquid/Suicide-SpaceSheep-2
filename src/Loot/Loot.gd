extends Area2D

export var energy = 3


func _on_Loot_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		set_physics_process(false)
		body.consume_loot(energy)
		# Not using :
		# set_deferred("monitoring", false)
		# because causing much lag
		set_collision_mask_bit(2, false)
		$AnimationPlayer.play("Despawn")
		$LootSound.play()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Despawn":
			queue_free()

func despawn():
	set_collision_mask_bit(2, false)
	$AnimationPlayer.play("Despawn")
