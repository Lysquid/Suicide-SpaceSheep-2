extends Area2D

export var speed = 800
export var direction : Vector2


func launch(player, world):
	set_physics_process(true)
	var tmp_position = global_position
	var tmp_rotation = global_rotation
	player.remove_child(self)
	world.add_child(self)
	remove_from_group("loaded_bullets")
	position = tmp_position
	rotation = tmp_rotation
	direction = direction.rotated(player.rotation)
	monitoring = true

func _physics_process(delta):
	position += direction * delta * speed


func _on_VisibilityNotifier2D_screen_exited() -> void:
	if not is_in_group("loaded_bullets"):
		queue_free()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Despawn":
			queue_free()

func _on_Bullet_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.die()
		set_physics_process(false)
		despawn()

func despawn():
	set_collision_mask_bit(1, false)
	$AnimationPlayer.play("Despawn")
