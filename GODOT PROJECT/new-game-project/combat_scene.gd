extends Node2D


# Ready relevant nodes on load/ready (references)
@onready var player_sprite: AnimatedSprite2D = $CombatPlayer
@onready var enemy_sprite: AnimatedSprite2D = $CombatEnemy
@onready var healing_sprite: AnimatedSprite2D = $CombatPlayer/PlayerHealing

@onready var status_label: Label = $UI/StatusLabel
@onready var player_hp_label: Label = $UI/PlayerIcon/PlayerHPLabel
@onready var enemy_hp_label: Label = $UI/EnemyIcon/EnemyHPLabel
@onready var log_label: Label = $UI/LogLabel
@onready var attack_button: TextureButton = $UI/AttackButton
@onready var skill_button: TextureButton = $UI/SkillButton
@onready var skill_text: Label = $UI/SkillButton/SkillText
@onready var heal_button: TextureButton = $UI/HealButton
@onready var heal_text: Label = $UI/HealButton/HealText
@onready var damage_number: DamageNumber = $DamageNumber
@onready var world_state = WorldMapState

# Setting up Game State variable starting with Enemy HP stats, Player stats are saved globally
var enemy_hp: int = 150
var enemy_max_hp: int = 150
# Remembers starting positions for later use
var player_original_pos: Vector2
var enemy_original_pos: Vector2

# Prevents button spam/multiple animations 
var is_player_turn: bool = true
var in_animation: bool = false
# Sets up skills cooldown system, current state of skill updates based on player turns 
var skill_cooldown_max: int = 3
var skill_cooldown_remaining: int = 0

var heal_cooldown_max: int = 5
var heal_cooldown_remaining: int = 0

# Battle start scene loading up
func _ready() -> void:
	# Store original positions to slide back after attacks
	player_original_pos = player_sprite.position
	enemy_original_pos = enemy_sprite.position
	
	# Start idle animations
	player_sprite.play("idle")
	enemy_sprite.play("idle")
	
	# Update UI on battle start and fires the opening log message
	update_hp_ui()
	log_label.text = "Battle Start!\n"
	# Connects the button presses to their respective functions later on
	attack_button.pressed.connect(on_attack_button_pressed)
	skill_button.pressed.connect(on_skill_button_pressed)
	heal_button.pressed.connect(on_heal_button_pressed)
	
	# Starting the first player turn
	start_player_turn()

# Player/Enemy HP labels ui update and dynamic color changes based on lower hp
func update_hp_ui() -> void:
	player_hp_label.text = "Player HP: %d / %d" % [world_state.player_hp, world_state.player_max_hp]
	player_hp_label.add_theme_color_override("font_color", Color.RED) if world_state.player_hp < 30 else Color.WHITE
	enemy_hp_label.text = "Enemy HP: %d / %d" % [enemy_hp, enemy_max_hp]
	enemy_hp_label.add_theme_color_override("font_color", Color.RED) if enemy_hp < 30 else Color.WHITE

# Abilities cooldown trackers and dynamic updates
func update_skill_button() -> void:
	if skill_cooldown_remaining > 0:
		skill_button.disabled = true
		skill_text.text = "Skill (%d)" % skill_cooldown_remaining
	else:
		skill_button.disabled = false
		skill_text.text = "Skill"
		
func update_heal_button() -> void:
	if heal_cooldown_remaining > 0:
		heal_button.disabled = true
		heal_text.text = "Heal (%d)" % heal_cooldown_remaining
	else:
		heal_button.disabled = false
		heal_text.text = "Heal"
		
# Turn logic and animation reset
func start_player_turn() -> void:
	is_player_turn = true
	attack_button.disabled = false
	skill_button.disabled = false
	heal_button.disabled = false
	
	# Decrements skills cooldown duration by 1 at the start of player turn
	if skill_cooldown_remaining > 0:
		skill_cooldown_remaining -= 1
	update_skill_button()
	
	if heal_cooldown_remaining > 0:
		heal_cooldown_remaining -= 1
	update_heal_button()
	
	in_animation = false

# Disables player input during enemy turn
func start_enemy_turn() -> void:
	is_player_turn = false
	attack_button.disabled = true
	skill_button.disabled = true
	heal_button.disabled = true
	in_animation = true
	
	# Creating a timer to act as a small pause between player and enemy actions
	await get_tree().create_timer(1).timeout
	if enemy_hp > 0:
		enemy_attack()

# Checks health after every attack, ends the battle when an entity dies and carries out respective functions
func check_win_condition() -> bool:
	if enemy_hp <= 0:
		attack_button.disabled = true
		skill_button.disabled = true
		heal_button.disabled = true
		log_label.text += "Victory!\n"
		world_state.player_experience += 500
		world_state.update_player_level()
		enemy_sprite.play("death")
		await get_tree().create_timer(0.5).timeout
		%Victory.visible = true
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://world_map.tscn")
		return true
	elif world_state.player_hp <= 0:
		attack_button.disabled = true
		skill_button.disabled = true
		heal_button.disabled = true
		log_label.text += "You Died\n"
		player_sprite.play("death")
		await get_tree().create_timer(0.5).timeout
		%GameOver.visible = true
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://main_menu.tscn")
		return true
	return false
	


# Player character attack flow and logic, ignores clicks if not player turn or an animation is playing
func on_attack_button_pressed() -> void:
	if not is_player_turn or in_animation:
		return
	
	in_animation = true
	attack_button.disabled = true
	skill_button.disabled = true
	heal_button.disabled = true
	
	player_attack()


func player_attack() -> void:
	
	# Play attack animation + movement
	player_sprite.play("attack")
	
	var tween = create_tween()
	# Player character will move 470 pixels in 0.5 seconds towards the enemy then attack
	tween.tween_property(player_sprite, "position", Vector2(player_original_pos.x + 470, player_original_pos.y), 0.50)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Damage logic and log update, happens after moving first
	tween.tween_callback(func():
		var damage = randi_range(world_state.player_attack_min, world_state.player_attack_max)
		var crit_chance = randf() < (world_state.player_crit_chance)
		# Critical chance function
		if crit_chance:
			damage *= (world_state.player_crit_damage)
			log_label.text += "%d CRITICAL DAMAGE!\n" % damage
		else: 
			log_label.text += "%d damage!\n" % damage
		enemy_hp = max(0, enemy_hp - damage)
		update_hp_ui()
		
		damage_number.spawn_label(damage, crit_chance, false, enemy_sprite.global_position)
		
		# Enemy model stretches out in reaction to being "hit", creates visual stimuli , 0.1s duration then returns to normal
		var hit_tween = create_tween()
		hit_tween.tween_property(enemy_sprite, "scale", Vector2(1.45, 0.65), 0.10)
		hit_tween.tween_property(enemy_sprite, "scale", Vector2(1.0, 1.0), 0.12)
	)
	
	# Player character returns to original position
	tween.tween_property(player_sprite, "position", player_original_pos, 0.45)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Ends player turn and returns to idle stance, then starts enemy turn
	tween.tween_callback(func():
		player_sprite.play("idle")
		in_animation = false
		
		if await check_win_condition():
			return
		start_enemy_turn()
	)
	
func on_skill_button_pressed() -> void:
	if not is_player_turn or in_animation:
		return
	
	in_animation = true
	skill_cooldown_remaining = skill_cooldown_max
	attack_button.disabled = true
	skill_button.disabled = true
	heal_button.disabled = true
	
	update_skill_button()
	player_skill()

	
func player_skill() -> void:
	
	# Play skill animation + movement
	player_sprite.play("skill")
	
	
	var tween = create_tween()
	# Player character will move 475 pixels in 0.6 seconds towards the enemy then attack
	tween.tween_property(player_sprite, "position", Vector2(player_original_pos.x + 475, player_original_pos.y), 0.60)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Damage logic and log update, happens after moving first
	tween.tween_callback(func():
		var damage = randi_range(world_state.player_skill_min, world_state.player_skill_max)*2
		var crit_chance = randf() < (world_state.player_crit_chance) + 0.10
		# Critical chance function
		if crit_chance:
			damage *= (world_state.player_crit_damage)
			log_label.text += "%d CRITICAL DAMAGE!\n" % damage
		else: 
			log_label.text += "%d damage!\n" % damage
		enemy_hp = max(0, enemy_hp - damage)
		update_hp_ui()
		
		damage_number.spawn_label(damage, crit_chance, false, enemy_sprite.global_position)
		
		# Enemy reaction to being hit
		var hit_tween = create_tween()
		hit_tween.tween_property(enemy_sprite, "scale", Vector2(1.45, 0.65), 0.10)
		hit_tween.tween_property(enemy_sprite, "scale", Vector2(1.0, 1.0), 0.12)
	)
	
	# Player character returns to original position
	tween.tween_property(player_sprite, "position", player_original_pos, 0.45)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Ends player turn and returns to idle stance, then starts enemy turn
	tween.tween_callback(func():
		player_sprite.play("idle")
		in_animation = false
		
		if await check_win_condition():
			return
		start_enemy_turn()
	)
func on_heal_button_pressed() -> void:
	if not is_player_turn or in_animation:
		return
	
	in_animation = true
	heal_cooldown_remaining = heal_cooldown_max
	attack_button.disabled = true
	skill_button.disabled = true
	heal_button.disabled = true
	
	update_heal_button()
	player_heal()

func player_heal() -> void:
	
	# Plays heal animation + movement
	healing_sprite.play("heal")
	
	
	var tween = create_tween()
	# Player character will move 1 pixel in 0.55 seconds towards the enemy then heal
	tween.tween_property(player_sprite, "position", Vector2(player_original_pos.x + 1, player_original_pos.y), 0.55)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Same use of damage logic applied to healing spell
	tween.tween_callback(func():
		var healing = randi_range(world_state.player_heal_min, world_state.player_heal_max)
		var critical_healing = randf() < (world_state.player_crit_chance)
		# Critical chance function
		if critical_healing:
			healing *= (world_state.player_crit_damage)
			log_label.text += "%d CRITICAL HEALING!\n" % healing
		else:
			log_label.text += "%d Player Healed!\n" % healing
		world_state.player_hp = min(world_state.player_max_hp, world_state.player_hp + healing)
		update_hp_ui()
		
		damage_number.spawn_label(healing, false, true, player_sprite.global_position)
	)
	
	# Player character returns to original position
	tween.tween_property(player_sprite, "position", player_original_pos, 0.55)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Ends player turn and returns to idle stance, then starts enemy turn
	tween.tween_callback(func():
		player_sprite.play("idle")
		in_animation = false
		
		if await check_win_condition():
			return
		start_enemy_turn()
	)

# Enemy turn AI logic
func enemy_attack() -> void:
	# Play attack animation + movement
	enemy_sprite.play("attack")
	
	var tween = create_tween()
	# Enemy character will move 470 pixels in 0.55 seconds towards the player then attack
	tween.tween_property(enemy_sprite, "position", Vector2(enemy_original_pos.x - 470, enemy_original_pos.y), 0.55)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Damage logic and log update, happens after moving first, locally saved values unlike player stats
	tween.tween_callback(func():
		var damage = randi_range(24, 28) - 0.40*(world_state.player_armor)
		var crit_chance = randf() < 0.15
		# Critical chance function
		if crit_chance:
			damage *= 1.5
			log_label.text += "%d CRITICAL DAMAGE!\n" % damage
		else: 
			log_label.text += "%d damage!\n" % damage
		world_state.player_hp = max(0, world_state.player_hp - damage)
		update_hp_ui()
		
		damage_number.spawn_label(damage, crit_chance, false, player_sprite.global_position)
		
		# Player reaction to being hit
		var hit_tween = create_tween()
		hit_tween.tween_property(player_sprite, "scale", Vector2(1.45, 0.65), 0.10)
		hit_tween.tween_property(player_sprite, "scale", Vector2(1.0, 1.0), 0.12)
	)
	
	# Enemy character returns to original position
	tween.tween_property(enemy_sprite, "position", enemy_original_pos, 0.45)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Ends enemy turn and returns to idle stance, then starts player turn
	tween.tween_callback(func():
		enemy_sprite.play("idle")
		in_animation = false
		
		if await check_win_condition():
			return
		start_player_turn()
	)
