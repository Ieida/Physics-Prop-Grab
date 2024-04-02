extends CharacterBody3D
class_name Player

const hud: PackedScene = preload("res://player/hud/hud.tscn")
static var HUD: Control
@export var camera: Camera3D
@export var move_force: float = 20
@export var max_speed: float = 4
@export var jump_force: float = 4
@export var wall_jump_force: float = 5
@export var gravity: float = 9.8

func _enter_tree():
	# Spawn HUD
	var h = hud.instantiate()
	get_tree().root.add_child.call_deferred(h)
	HUD = h

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Get input
	var input = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	
	# Create movement vector
	var movement = Vector3.ZERO
	var right = camera.global_basis.x if camera else global_basis.x
	var normal = get_floor_normal()
	var forward = right.cross(normal)
	movement = (forward * -input.y) + (right * input.x)
	movement *= move_force * delta
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity += get_floor_normal() * jump_force
		elif is_on_wall():
			var n = (get_wall_normal() + up_direction).normalized()
			velocity += n * wall_jump_force
	
	# Gravity
	if not is_on_floor():
		add_velocity(Vector3(0, -gravity * delta, 0), gravity)
	
	# Move
	if is_on_floor():
		add_velocity(movement, max_speed)
		var nv = velocity.move_toward(Vector3.ZERO, 10.0 * delta)
		nv.y = velocity.y
		velocity = nv
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_mouse_mode()

func add_velocity(amount: Vector3, max: float):
	var dot = amount.normalized().dot(velocity.normalized())
	dot = clampf(dot, 0, 1)
	var vel_in_dir = velocity * dot
	var spd_in_dir = vel_in_dir.length()
	var remaining_velocity = clampf(max - spd_in_dir, 0, max)
	var vel = clampf(amount.length(), 0, remaining_velocity)
	velocity += amount.normalized() * vel

func toggle_mouse_mode():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
