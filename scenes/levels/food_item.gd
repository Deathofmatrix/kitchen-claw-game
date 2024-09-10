extends CharacterBody2D

@export var speed: int = 100

func _physics_process(delta):
	velocity.x = -1 * speed
	move_and_slide()
