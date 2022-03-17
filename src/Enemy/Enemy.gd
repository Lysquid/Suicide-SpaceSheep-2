extends Area2D

export (int) var speed = 180
export (float) var acceleration = 0.2

export var rotation_speed = 0.25
export var direction : Vector2
export (PackedScene) var Loot

onready var player = get_parent().player

func _physics_process(delta):
	
	if not player.dead:
		direction = direction.slerp(position.direction_to(player.position), rotation_speed * delta)
	
	position += direction * speed * delta
	rotation = direction.angle()

func player_died():
	$AnimationPlayer.play("Freeze")
	
func die():
	set_collision_layer_bit(3, false)
	set_collision_mask_bit(1, false)	
	call_deferred("spawn_loot")
	set_physics_process(false)
	$DieSound.play()
	$AnimationPlayer.play("Death")
	player.killed_enemy()

func spawn_loot():
	var loot = Loot.instance()
	get_parent().add_child(loot)
	loot.position = position


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Death":
			queue_free()
		"Freeze":
			pass

func despawn():
	set_collision_mask_bit(1, false)
	$AnimationPlayer.play("Death")


func _on_Enemy_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.die()
