extends Camera2D

@export var speed = .6

func _process(delta: float) -> void:
	global_rotation_degrees = lerpf(global_rotation_degrees, 0, speed * delta)
