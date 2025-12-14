extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sens := 5.0

@onready var cam = $pivote


func _input(event: InputEvent) -> void:
		if event is InputEventJoypadMotion:
			cam.rotate_z(deg_to_rad(-event.relative.x * sens))
			cam.rotate_x(deg_to_rad(-event.relative.y * sens))
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(45))
			
func _physics_process(delta: float) -> void:
	movimiento(delta)
	move_and_slide()
	
func movimiento(delta:float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
