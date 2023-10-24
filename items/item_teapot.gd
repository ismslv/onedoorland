extends Interactive

func switch(state):
	$GPUParticles3D.emitting = state
	if state:
		$Timer.start(5)
	else:
		$Timer.stop()

func _on_timer_timeout():
	$GPUParticles3D.emitting = false
