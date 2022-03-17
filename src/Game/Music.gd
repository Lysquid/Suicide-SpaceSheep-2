extends AudioStreamPlayer

const TRACKS = [ 'Fight', 'BossFight', 'Hyper', 'The Flute ChipTune' ]
var track_nb = -1

func _ready() -> void:
	play_random_music()
	$AnimationPlayer.play("Higher")
	play()
	# TY : https://godotengine.org/qa/32310/how-to-stop-looping-in-audio

func play_random_music():
	stop()
	var random_track_nb = track_nb
	while track_nb == random_track_nb:
		random_track_nb = randi() % TRACKS.size()
	track_nb = random_track_nb
	var track = load('res://music/' + TRACKS[track_nb] + '.mp3')
	set_stream(track)
	var casted_stream = stream as AudioStreamMP3
	casted_stream.set_loop(false)
	$DelayTimer.start()

func _on_DelayTimer_timeout() -> void:
	if not playing:
		play()
	


func _on_Player_died() -> void:
	$AnimationPlayer.play("Lower")


func _on_Menu_start() -> void:
	if volume_db < 0:
		$AnimationPlayer.play("Higher")
