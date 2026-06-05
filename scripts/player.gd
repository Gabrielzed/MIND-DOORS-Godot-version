extends CharacterBody3D

# ==================================================
# CONFIG
# ==================================================

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

# VELOCIDADE DA ROTAÇÃO DO OBJETO
const OBJECT_ROTATION_SPEED = 0.2

# FORÇA PARA SEGURAR O OBJETO
const HOLD_FORCE = 10.0

# ==================================================
# GRAVIDADE
# ==================================================

var gravity = ProjectSettings.get_setting(
	"physics/3d/default_gravity"
)

# ==================================================
# NODES
# ==================================================

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var hold_position = $Camera3D/HoldPosition

# ==================================================
# SISTEMA DE OBJETO
# ==================================================

var held_object = null

# VALOR DA ROTAÇÃO DO SCROLL
var scroll_rotation = 0.0

# ==================================================
# READY
# ==================================================

func _ready():

	Input.set_mouse_mode(
		Input.MOUSE_MODE_CAPTURED
	)

# ==================================================
# INPUT
# ==================================================

func _unhandled_input(event):

	# ------------------------------------------
	# MOVIMENTO DA CAMERA
	# ------------------------------------------

	if event is InputEventMouseMotion:

		# ROTACIONAR PLAYER
		rotate_y(
			-event.relative.x *
			MOUSE_SENSITIVITY
		)

		# ROTACIONAR CAMERA
		camera.rotate_x(
			-event.relative.y *
			MOUSE_SENSITIVITY
		)

		# LIMITAR CAMERA
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)

	# ------------------------------------------
	# LIBERAR MOUSE
	# ------------------------------------------

	if event.is_action_pressed(
		"ui_cancel"
	):

		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE
		)

	# ------------------------------------------
	# ROTAÇÃO COM SCROLL
	# ------------------------------------------

	if held_object:

		# SCROLL PRA CIMA
		if event.is_action_pressed(
			"wheel_up"
		):

			scroll_rotation = 1.0

		# SCROLL PRA BAIXO
		if event.is_action_pressed(
			"wheel_down"
		):

			scroll_rotation = -1.0

# ==================================================
# PHYSICS
# ==================================================

func _physics_process(delta):

	# ------------------------------------------
	# GRAVIDADE
	# ------------------------------------------

	if not is_on_floor():

		velocity.y -= gravity * delta

	# ------------------------------------------
	# PULO
	# ------------------------------------------

	if Input.is_action_just_pressed(
		"jump"
	):

		if is_on_floor():

			velocity.y = JUMP_VELOCITY

	# ------------------------------------------
	# MOVIMENTO
	# ------------------------------------------

	var input_dir = Input.get_vector(

		"move_left",
		"move_right",
		"move_forward",
		"move_back"

	)

	var direction = (

		transform.basis *

		Vector3(
			input_dir.x,
			0,
			input_dir.y
		)

	).normalized()

	# MOVIMENTO
	if direction:

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	# PARAR
	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			SPEED
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			SPEED
		)

	move_and_slide()

	# ------------------------------------------
	# PEGAR / SOLTAR OBJETO
	# ------------------------------------------

	if Input.is_action_just_pressed(
		"mouse_click"
	):

		if held_object:

			drop_object()

		else:

			pick_object()

	# ------------------------------------------
	# MOVER OBJETO
	# ------------------------------------------

	if held_object:

		move_held_object()

		# ----------------------------------
		# ROTACIONAR OBJETO NO Y
		# ----------------------------------

		held_object.rotation.y += (
			scroll_rotation *
			OBJECT_ROTATION_SPEED
		)

		# RESETAR SCROLL
		scroll_rotation = 0.0

# ==================================================
# PEGAR OBJETO
# ==================================================

func pick_object():

	if raycast.is_colliding():

		var obj = raycast.get_collider()

		if obj is RigidBody3D:

			held_object = obj

			# GARANTIR FÍSICA
			held_object.freeze = false

# ==================================================
# MOVER OBJETO
# ==================================================

func move_held_object():

	var target_position = (

		hold_position
		.global_transform
		.origin

	)

	var direction = (

		target_position -

		held_object
		.global_transform
		.origin

	)

	held_object.linear_velocity = (
		direction * HOLD_FORCE
	)

# ==================================================
# SOLTAR OBJETO
# ==================================================

func drop_object():

	held_object = null
