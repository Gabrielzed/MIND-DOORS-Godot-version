extends CharacterBody3D

# ==================================================
# CONFIG
# ==================================================

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
const OBJECT_ROTATION_SPEED = 0.2
const HOLD_FORCE = 12.0

# ==================================================
# GRAVIDADE
# ==================================================

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ==================================================
# NODES (PASSO 4)
# ==================================================

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var hold_position = $Camera3D/HoldPosition

@onready var fade = $CanvasLayer/Fade
@onready var world_environment = $"../WorldEnvironment"

# ==================================================
# VARIÁVEIS (PASSO 5)
# ==================================================

var held_object: RigidBody3D = null
var is_sleeping = false
var scroll_rotation = 0.0


# ==================================================
# READY
# ==================================================

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# ==================================================
# INPUT CAMERA + INTERAÇÃO
# ==================================================

func _unhandled_input(event):

	if is_sleeping:
		return

	# ---------------- CAMERA ----------------
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)

		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)

	# ---------------- SCROLL OBJETO ----------------
	if held_object:

		if event.is_action_pressed("wheel_up"):
			scroll_rotation += 1.0

		if event.is_action_pressed("wheel_down"):
			scroll_rotation -= 1.0


# ==================================================
# PHYSICS (PASSO 6)
# ==================================================

func _physics_process(delta):

	if is_sleeping:
		return

	# ---------------- GRAVIDADE ----------------
	if not is_on_floor():
		velocity.y -= gravity * delta

	# ---------------- PULO ----------------
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# ---------------- MOVIMENTO ----------------
	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# ---------------- PEGAR / SOLTAR OBJETO ----------------
	if Input.is_action_just_pressed("mouse_click"):

		if held_object:
			drop_object()
		else:
			pick_object()

	# ---------------- INTERAÇÃO (PASSO 12/13) ----------------
	if Input.is_action_just_pressed("interact"):

		if raycast.is_colliding():

			var obj = raycast.get_collider()

			if obj.has_method("interact"):
				obj.interact(self)

	# ---------------- MOVIMENTO DO OBJETO ----------------
	if held_object and is_instance_valid(held_object):

		move_held_object()

		held_object.rotation.y += scroll_rotation * OBJECT_ROTATION_SPEED

		scroll_rotation = lerp(scroll_rotation, 0.0, 0.2)


# ==================================================
# PEGAR OBJETO
# ==================================================

func pick_object():

	if raycast.is_colliding():

		var obj = raycast.get_collider()

		if obj is RigidBody3D:

			held_object = obj
			held_object.freeze = false


# ==================================================
# MOVER OBJETO
# ==================================================

func move_held_object():

	if not is_instance_valid(held_object):
		held_object = null
		return

	var target_position = hold_position.global_transform.origin

	var direction = target_position - held_object.global_transform.origin

	held_object.apply_central_force(direction * HOLD_FORCE * 10.0)


# ==================================================
# SOLTAR OBJETO
# ==================================================

func drop_object():
	held_object = null


# ==================================================
# SLEEP (PASSO 7)
# ==================================================

func sleep():

	if is_sleeping:
		return

	is_sleeping = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	await sleep_animation()

	get_tree().change_scene_to_file("res://scenes/Dia2.tscn")


# ==================================================
# ANIMAÇÃO COMPLETA (PASSO 8)
# ==================================================

func sleep_animation():

	var env = world_environment.environment
	env.dof_blur_far_enabled = true

	var tween = create_tween()

	# deitar cabeça + blur
	tween.parallel().tween_property(
		camera,
		"rotation:x",
		deg_to_rad(-90),
		2.0
	)

	tween.parallel().tween_property(
		env,
		"dof_blur_far_amount",
		0.4,
		2.0
	)

	await tween.finished

	await blink()
	await blink()
	await blink()

	await fade_black()


# ==================================================
# PISCADA (PASSO 9)
# ==================================================

func blink():

	fade.color.a = 0

	var tween = create_tween()

	tween.tween_property(fade, "color:a", 1.0, 0.10)
	tween.tween_interval(0.10)
	tween.tween_property(fade, "color:a", 0.0, 0.10)

	await tween.finished
	await get_tree().create_timer(0.25).timeout


# ==================================================
# FADE PRETO (PASSO 10)
# ==================================================

func fade_black():

	var tween = create_tween()

	tween.tween_property(fade, "color:a", 1.0, 1.5)

	await tween.finished
