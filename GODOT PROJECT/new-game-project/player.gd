extends CharacterBody2D

# State of the player, should be one of three at all times
enum State {
	IDLE,
	RUN,
	ATTACK,
}

# Exports Player node "Stats" category into Inspector
@export_category("Stats")
@export var speed: int = 400
@export var attack_speed: float = 0.6
@export var attack_initiate: int = 10

# Storing the movement action as a variable for ease of access, setting IDLE as the default state
var state: State = State.IDLE
var move_direction: Vector2 = Vector2(0, 0)

# Saving references to the animation tree, SMP class allows travel between states
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var hitbox: Area2D = $HitBox
@onready var health_bar: Label = $PlayerIcon/PlayerLabelHP
@onready var experience_bar: Label = $PlayerIcon/ExperienceLabel
@onready var player_level: Label = $PlayerIcon/LevelBanner/LevelLabel
@onready var world_state = WorldMapState

# Activates the animation tree on game start
func _ready() -> void:
	animation_tree.set_active(true)	
	update_hp_ui()
	update_xp_ui()
	update_lvl_ui()

# Function to set up attack on mouse input, unhandled to prevent attack from playing when other screens are open
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()
	if event.is_action_pressed("go_to_camp"):
		move_to_camp()
	if event.is_action_pressed("return_to_map"):
		move_to_map()
		
# Default function in engine for physics, movement_loop called at 60fps 
func _physics_process(_delta: float) -> void:
	if not state == State.ATTACK:
		movement_loop()
		
	var count = get_slide_collision_count()
	if count > 0:
		print("Colliding with: ", get_slide_collision(0).get_collider().name)

# Defines the movement direction on the X and Y axis, inputs were set through: Project > Settings > Input Map
func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))	
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	# motion var to set up the motion of the character, using built in functions
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
		
# Sprite flipping for idle/run
	if state != State.ATTACK:
		if move_direction.x < -0.01:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0.01:
			$Sprite2D.flip_h = false

# Loop that picks up on player state so it knows when the player is running/idling
	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()
		
func move_to_camp() -> void:
	get_tree().change_scene_to_file("res://rest_camp.tscn")

func move_to_map() -> void:
	get_tree().change_scene_to_file("res://world_map.tscn")
	
# Func to update the animation according to key inputs,'travel' key word possible due to Animation Tree and SMP
func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
			
 # Func to show a Player icon and the HP the player currently has
func update_hp_ui() -> void:
	health_bar.text = "Player HP: %d / %d" % [world_state.player_hp, world_state.player_max_hp]
	health_bar.add_theme_color_override("font_color", Color.RED) if world_state.player_hp < 30 else Color.WHITE

func update_xp_ui() -> void:
	experience_bar.text = "Player XP: %d / %d" % [world_state.player_experience, world_state.player_max_experience]

func update_lvl_ui() -> void:
	player_level.text = "%d" % [world_state.player_level]
	
func attack() -> void:
	# Verifies the player is not already attacking
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	# Find the attack direction and reference to animation tree blendspace2d
	var mouse_pos: Vector2 = get_global_mouse_position()
	var attack_dir: Vector2 = (mouse_pos - global_position).normalized()
	# Call to flip the sprite depending on cursor position when attacking,works through blendspace2d
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	# Return player state after attack has finished, based on attack speed var
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	print("HitBox touched:", area.name)
	print("Owner:", area.owner)
	area.owner.take_damage(attack_initiate)
