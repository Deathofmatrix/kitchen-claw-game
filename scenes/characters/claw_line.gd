extends Line2D

@onready var claw_attatch = %ClawAttatch

func _process(delta):
	set_point_position(1, claw_attatch.global_position - global_position)
