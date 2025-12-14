extends CharacterBody3D

# --- PROPIEDADES ---
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 14.0 
const MOUSE_SENSITIVITY = 0.002

# Rutas corregidas, asumiendo que CamaraBoom es hijo directo del Personaje (self)
@onready var camera_boom = $CamaraBoom 
@onready var mesh = $MeshInstance3D

var direction = Vector3.ZERO # Dirección de movimiento

# --- FÍSICA Y MOVIMIENTO (CharacterBody3D) ---
func _physics_process(delta):
	# 1. Aplicar la gravedad
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# 2. Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Obtener la entrada del movimiento (A/D/S/W)
	var input_dir = Input.get_vector("izquierda_wasd", "derecha_wasd","atras_wasd", "delante_wasd")
	
	# Mapear la entrada 2D (input_dir) a un vector 3D basado en la rotación del personaje (self.transform)
	if input_dir.length_squared() > 0:
		var forward = -transform.basis.z
		var right = transform.basis.x
		
		# El vector 'input_dir.y' va de -1 (atrás) a 1 (adelante)
		# El vector 'input_dir.x' va de -1 (izquierda) a 1 (derecha)
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
	else:
		direction = Vector3.ZERO
	
	# 4. Aplicar el movimiento en los ejes X y Z
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# Desaceleración suave
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 5. Ejecutar el movimiento
	move_and_slide()
	
	# Bloquear el cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --- ENTRADA DEL RATÓN (Rotación) ---
func _input(event):
	if event is InputEventMouseMotion:
		# Rotación Horizontal: Rota el CharacterBody3D completo (eje Y)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotación Vertical: Rota solo el SpringArm3D (eje X)
		var new_x_rot = camera_boom.rotation.x - event.relative.y * MOUSE_SENSITIVITY
		# Se asegura que la cámara no dé una vuelta completa (clamps)
		camera_boom.rotation.x = clamp(new_x_rot, deg_to_rad(-60), deg_to_rad(30))
