extends KinematicBody2D

signal died
signal low_energy
signal new_high_score
signal score_changed

export (int) var normal_speed = 150
export (int) var fast_speed = 400
export (float) var acceleration = 0.1
export (int) var max_rotation_speed = 7
export (float) var rotation_acceleration = 0.1
export (float) var rotation_decceleration = 0.3
export (PackedScene) var Bullet
export var bullet_spread = PI/8
export var dash_cost = 1

var direction = Vector2.RIGHT
var rotation_speed : float
export var speed : float
var energy : int
var player_controlled : bool
var dead : bool
var bullet_count : int
var score : int

var particles = preload("res://src/Player/Particules.tres")
var high_score = 0

func _ready():
	set_physics_process(false)
	$BoostParticles.emitting = false

func start():
	direction = Vector2.RIGHT
	rotation_speed = 0
	speed = 0
	energy = 0
	player_controlled = true
	bullet_count = 0
	score = 0
	
	set_physics_process(true)
	set_collision_layer_bit(1, true)
	if dead:
		$AnimationPlayer.play("Spawn")
	dead = false
	$DeathParticles.restart()
	$DeathParticles.emitting = false
	$BoostParticles.emitting = true

func _physics_process(delta):
	
	if player_controlled:
		apply_rotation(delta)
		apply_acceleration()
		dash()
	
	particles.initial_velocity = speed
	var _tmp = move_and_slide(direction * speed)
	shoot()
	
func apply_rotation(delta):
	var input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	rotation_speed = lerp(rotation_speed, input, rotation_acceleration if input else rotation_decceleration)
	direction = direction.rotated(rotation_speed * delta * max_rotation_speed)
	rotation = direction.angle()
	
func apply_acceleration():
	if Input.is_action_pressed("ui_up"):
		speed = lerp(speed, fast_speed, acceleration)
	else:
		speed = lerp(speed, normal_speed, acceleration)
	if Input.is_action_just_pressed("ui_up"):
		$AccelerateSound.play()
	if Input.is_action_just_released("ui_up"):
		$DecelerateSound.play()

func die():
	dead = true
	set_physics_process(false)
	set_collision_layer_bit(1, false)
	$AnimationPlayer.play("Death")
	$NewBulletTimer.stop()
	$DieSound.play()
	get_tree().call_group("loaded_bullets", "despawn")
	
	if score > high_score:
		high_score = score
		emit_signal("new_high_score")
		$HighScoreSound.play()
	
	emit_signal("died")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Death":
			pass
		"Dash":
			set_collision_layer_bit(1, true)
			set_collision_layer_bit(2, true)
			player_controlled = true

func shoot():
	if Input.is_action_just_pressed("ui_select"):
		add_bullet()
		$NewBulletTimer.start()
	if Input.is_action_just_released("ui_select"):
		$NewBulletTimer.stop()
		if bullet_count > 0:
			get_tree().call_group("loaded_bullets", "launch", self, get_parent())
			if bullet_count == 1:
				$ShootSound.play()
			else:
				$MultiShootSound.play()
			bullet_count = 0

func add_bullet() -> void:
	if energy > 0:
		var bullet = Bullet.instance()
		add_child(bullet)
		bullet.add_to_group("loaded_bullets")
		bullet.set_physics_process(false)
		var bullet_pos = 0
		if bullet_count%2 == 0:
			if bullet_count != 0:
				# warning-ignore:integer_division
				bullet_pos = bullet_count  / 2 
		else:
			# warning-ignore:integer_division
			bullet_pos = - (bullet_count + 1) / 2
		var bullet_direction = Vector2.RIGHT.rotated(bullet_pos * bullet_spread)
		bullet.direction = bullet_direction
		bullet.rotation = bullet_direction.angle()
		bullet.position += bullet_direction * 60
		energy -= 1
		if bullet_count > 0:
			$LoadBulletSound.play()
		bullet_count += 1
		if bullet_count > 16:
			$NewBulletTimer.stop()
	else:
		emit_signal("low_energy")

func dash():
	if Input.is_action_just_pressed("dash"):
		if energy >= dash_cost:
			set_collision_layer_bit(1, false)
			set_collision_layer_bit(2, false)
			$AnimationPlayer.play("Dash")
			$DashSound.play()
			player_controlled = false
			energy -= dash_cost
		else:
			emit_signal("low_energy")

func _on_Player_low_energy() -> void:
	$LowEnergySound.play()

func killed_enemy():
	score += 1
	emit_signal("score_changed")

func consume_loot(loot_energy):
	energy += loot_energy
