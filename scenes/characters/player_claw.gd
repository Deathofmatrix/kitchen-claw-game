extends CharacterBody2D

const ACCELERATION = 1200
const MAX_SPEED = 200
const FRICTION = 1000
const CLAW_ACCELERATION = 200
const MAX_ClAW_LENGTH = 250

enum States {MOVE, EXTEND_CLAW, GRAB, RETRACT_CLAW, DROP}

@onready var claw_spring = %ClawSpring
@onready var claw_sprite = %ClawSprite

var state = States.MOVE

var cached_claw_length: float
var held_item: RigidBody2D


func _ready():
	cached_claw_length = claw_spring.rest_length


func _input(_event):
	if Input.is_action_just_pressed("drop_claw"):
		if held_item != null:
			change_state(States.DROP)
		else:
			change_state(States.EXTEND_CLAW)


func _process(_delta):
	if state != States.MOVE:
		velocity.x = 0


func _physics_process(delta):
	match state:
		States.MOVE:
			var direction = Input.get_axis("move_left", "move_right")
			move(direction, delta)
		States.EXTEND_CLAW:
			extend_claw(delta)
		States.GRAB:
			grab()
		States.RETRACT_CLAW:
			retract_claw(delta)
		States.DROP:
			drop()
	move_and_slide()


func change_state(newstate):
	state = newstate


func move(direction, delta):
	if direction:
		velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


func extend_claw(delta):
	claw_spring.rest_length = move_toward(claw_spring.rest_length, MAX_ClAW_LENGTH, CLAW_ACCELERATION * delta)
	
	if claw_spring.rest_length >= MAX_ClAW_LENGTH:
		change_state(States.GRAB)


func grab():
	await get_tree().create_timer(1).timeout
	change_state(States.RETRACT_CLAW)
 

func retract_claw(delta):
	claw_spring.rest_length = move_toward(claw_spring.rest_length, cached_claw_length, CLAW_ACCELERATION * delta)
	
	if claw_spring.rest_length <= cached_claw_length:
		change_state(States.MOVE)


func drop():
	held_item = null
