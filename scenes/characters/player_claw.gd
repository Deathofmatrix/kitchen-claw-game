extends CharacterBody2D

const ACCELERATION = 1200
const MAX_SPEED = 200
const FRICTION = 1000
const CLAW_ACCELERATION = 200
const MAX_ClAW_LENGTH = 260

enum States {MOVE, EXTEND_CLAW, GRAB, RETRACT_CLAW, DROP}

@onready var claw_spring = %ClawSpring
@onready var claw_sprite: Sprite2D = %ClawSprite

var state = States.MOVE

var cached_claw_length: float
var held_item: RigidBody2D
var is_animating_claw: bool = false


func _ready():
	cached_claw_length = claw_spring.rest_length


func _input(_event):
	if Input.is_action_just_pressed("drop_claw"):
		if held_item != null:
			change_state(States.DROP)
		elif state == States.MOVE:
			change_state(States.EXTEND_CLAW)
		else:
			pass


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
	if is_animating_claw: return
	is_animating_claw = true
	var tween = get_tree().create_tween()
	tween.tween_property(claw_sprite, "frame", claw_sprite.hframes -1, 1).finished
	await tween.finished
	change_state(States.RETRACT_CLAW)
	is_animating_claw = false

 

func retract_claw(delta):
	claw_spring.rest_length = move_toward(claw_spring.rest_length, cached_claw_length, CLAW_ACCELERATION * delta)
	if claw_spring.rest_length <= cached_claw_length:
		change_state(States.MOVE)


func drop():
	if is_animating_claw: return
	is_animating_claw = true
	var tween = get_tree().create_tween()
	tween.tween_property(claw_sprite, "frame", 0, 1).finished
	await tween.finished
	held_item = null
	change_state(States.RETRACT_CLAW)
	is_animating_claw = false


func _on_claw_body_entered(body):
	print(body.name)
	body.queue_free()


func _on_catch_area_body_entered(body):
	print(body.name)
	body.queue_free()
