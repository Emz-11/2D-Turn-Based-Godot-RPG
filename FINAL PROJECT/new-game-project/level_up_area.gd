extends Area2D

# Creating appropriate buttons to be used for leveling up and connecting to the global script

@onready var vigor_button: TextureButton = $"../LevelUpUI/CharacterSheet/+ Vigor"
@onready var strength_button: TextureButton = $"../LevelUpUI/CharacterSheet/+ Strength"
@onready var dexterity_button: TextureButton = $"../LevelUpUI/CharacterSheet/+ Dexterity"
@onready var armor_button: TextureButton = $"../LevelUpUI/CharacterSheet/+ Armor"
@onready var close_button: TextureButton = $"../LevelUpUI/CharacterSheet/CloseButton"
@onready var vigor_text: Label =$"../LevelUpUI/CharacterSheet/Vigor"
@onready var strength_text: Label =$"../LevelUpUI/CharacterSheet/Strength"
@onready var dexterity_text: Label =$"../LevelUpUI/CharacterSheet/Dexterity"
@onready var armor_text: Label =$"../LevelUpUI/CharacterSheet/Armor"
@onready var skill_points: Label =$"../LevelUpUI/CharacterSheet/SkillPoints"
@onready var level_up_ui = $"../LevelUpUI"
@onready var player_character = $"../Player"
@onready var world_state = WorldMapState

# Prepping button functions

func _ready() -> void:
	vigor_button.pressed.connect(vigor_stat_up)
	strength_button.pressed.connect(strength_stat_up)
	dexterity_button.pressed.connect(dexterity_stat_up)
	armor_button.pressed.connect(armor_stat_up)
	close_button.pressed.connect(close_sheet)

# Refresh function meant to keep the scenes looking dynamic as it updates while increasing player stats

func refresh():
	skill_points.text= str("Skill Points: ", (world_state.skill_points))
	vigor_text.text = str("Vigor: ", (world_state.player_vigor))
	strength_text.text = str("Strength: ", (world_state.player_strength))
	dexterity_text.text = str("Dexterity: ", (world_state.player_dexterity))
	armor_text.text = str("Armor: ", (world_state.player_armor))

# Button logic for increasing player stats, calls on 2 functions to update player stats globally
# then refresh the stat screen with accurate global information

func vigor_stat_up() -> void:
	if world_state.skill_points >0:
		world_state.skill_points -= 1
		world_state.player_vigor += 3
		world_state.recalculate_stats()
		refresh()

func strength_stat_up() -> void:
	if world_state.skill_points >0:
		world_state.skill_points -= 1
		world_state.player_strength += 3
		world_state.recalculate_stats()
		refresh()
		
func dexterity_stat_up() -> void:
	if world_state.skill_points >0:
		world_state.skill_points -= 1
		world_state.player_dexterity += 3
		world_state.recalculate_stats()
		refresh()

func armor_stat_up() -> void:
	if world_state.skill_points >0:
		world_state.skill_points -= 1
		world_state.player_armor += 3
		world_state.recalculate_stats()
		refresh()

# Collision logic for player approach and a simple close button for the stat screen

func _on_body_entered(body):
		level_up_ui.visible = true
		refresh()
		print("Entered: ", body.name)
		
func close_sheet() -> void:
	level_up_ui.visible = false
	refresh()
