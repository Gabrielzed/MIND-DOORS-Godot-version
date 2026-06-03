extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var hold_position = $Camera3D/HoldPosition

var held_object = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)

		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)

func _physics_process(delta):

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= gravity * delta

	# MOVIMENTO
	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction = (transform.basis * Vector3(
		input_dir.x,
		0,
		input_dir.y
	)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# PEGAR OBJETO
	if Input.is_action_just_pressed("mouse_click"):
		if held_object:
			drop_object()
		else:
			pick_object()

	# MANTER OBJETO NA FRENTE
	if held_object:
		move_held_object()

func pick_object():

	if raycast.is_colliding():

		var obj = raycast.get_collider()

		if obj is RigidBody3D:

			held_object = obj

			held_object.freeze = false

func move_held_object():

	var target_position = hold_position.global_transform.origin

	var direction = target_position - held_object.global_transform.origin

	held_object.linear_velocity = direction * 10.0

func drop_object():

	held_object = null
