extends CharacterBody2D

# simple purpose character, appear in the world to make it feel more alive
# and play an animation to signal the player they have been healed
# uses the same logic to react to player character hitbox as enemy npc scripts
# by making the healing animation visible and updating player global health

@onready var monk_sprite: AnimatedSprite2D = $Monk
@export  var  health_combat_start:int = 10
@onready var monk_healing: AnimatedSprite2D = $MonkHealing
@onready var player_character = $"../Player"
@onready var world_state = WorldMapState

func take_damage(damage_taken: int) -> void:
	health_combat_start -= damage_taken
	if health_combat_start <= 0:
		heal_area()

func heal_area() -> void:
	world_state.player_hp = world_state.player_max_hp
	monk_healing.visible = true
	monk_healing.play("healing_monk")
