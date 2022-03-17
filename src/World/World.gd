extends Node2D


export (PackedScene) var Loot
export (PackedScene) var Enemy
export (PackedScene) var Player

var wave : int

onready var player = get_node("Player")
onready var viewport_size = get_viewport_rect().size
onready var spawn_point = Vector2(viewport_size.x / 4, viewport_size.y / 2)

func _ready() -> void:
	randomize()
	player.position = spawn_point

func _on_Menu_start() -> void:
	get_tree().call_group("objects", "despawn")
	# Player
	player.position = spawn_point
	player.start()
	# Loots
	spawn_random_loots(10)
	# Enemies
	wave = 0
	$NewWaveTimer.start()
	new_wave()
	# HUD
	get_parent().get_node("HUD").init(self, player)
	# World
	$StartSound.play()
	
func spawn_random_loots(nb):
	for _i in range(nb):
		var loot = Loot.instance()
		add_child(loot)
		loot.position = Vector2(rand_range(0, viewport_size.x), rand_range(0, viewport_size.y))
	
func _on_Player_died() -> void:
	get_tree().call_group("enemies", "player_died")
	$NewWaveTimer.stop()

func new_wave() -> void:
	if wave > 0:
		$NewWaveSound.play()
	wave += 1
	for _i in range(wave):
		var enemy = Enemy.instance()
		add_child(enemy)
		$EnemySpawn/PathFollow2D.offset = randi()
		enemy.position = $EnemySpawn/PathFollow2D.position
		enemy.direction = enemy.position.direction_to(player.position)
		enemy.rotation = enemy.direction.angle()
