extends Node2D

# Player character stats, saved globally for consistency throughout the game and script calls
# Made global through Project > Settings > Globals

var player_level: int = 1
var player_experience: float = 0
var player_max_experience: float = 100
var player_strength: int = 5
var player_dexterity: int = 5
var player_vigor: int = 5
var player_armor: int = 5
var player_hp: float = 96 + 0.80*(player_vigor)
var player_max_hp: float = 96 + 0.80*(player_vigor)
var player_attack_min: float = 15 + 0.80*(player_strength)
var player_attack_max: float = 20 + 0.80*(player_strength)
var player_skill_min: float = 20 + 0.80*(player_strength)
var player_skill_max: float = 25 + 0.80*(player_strength)
var player_heal_min: float = 25 + 0.50*(player_vigor)
var player_heal_max: float = 35 + 0.50*(player_vigor)
var player_crit_chance: float = 0.15 + 0.005*(player_dexterity)
var player_crit_damage:  float = 1.5 + 0.005*(player_dexterity)
var skill_points: int = 0

# Creates an array to keep count of enemy data, including how many are on the map and which one is defeated
var defeated_enemies: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_player_level()
	
# Global enemy functions, keeps track of individual enemies based on id
func defeat_enemy(enemy_id: String) -> void:
	if not defeated_enemies.has(enemy_id):
		defeated_enemies.append(enemy_id)
		print("Defeated enemies saved: ", enemy_id, "Total defeated: ", defeated_enemies.size())
	
func enemy_defeated(enemy_id: String) -> bool:
	return defeated_enemies.has(enemy_id)
	
# Function to update player level when experience reaches maximum
# and increase the amount of experience needed for next level
# Also rewards player character with one of each stat and skill points to spend at their discretion

func update_player_level() -> void:
	while player_experience >= player_max_experience:
		player_experience -= player_max_experience
		player_max_experience += 30
		player_level += 1
		player_strength += 1
		player_dexterity += 1
		player_vigor += 1
		player_armor += 1
		skill_points += 3
		print("Player has ", skill_points, " skill points")

# Function to recalculate and update stats whenever the player levels them up

func recalculate_stats() -> void:
	player_max_hp = 95 + player_vigor
	player_attack_min = 15 + int(0.6 * player_strength)
	player_attack_max = 25 + int(0.6 * player_strength)
	player_skill_min = 25 + int(0.8 * player_strength)
	player_skill_max = 35 + int(0.8 * player_strength)
	player_heal_min = 25 + int(0.75 * player_vigor)
	player_heal_max = 35 + int(0.75 * player_vigor)
	player_crit_chance = 0.15 + (0.005 * player_dexterity)
	player_crit_damage = 1.5 + (0.005 * player_dexterity)
