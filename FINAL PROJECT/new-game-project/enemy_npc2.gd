extends CharacterBody2D

# Very simple logic for world enemies, lose hitpoints on contatct which triggers a scene change
# and drags the player into the real combat scene, enemy id is created and used by global script to
# keep track of defeated enemies and prevent them from spawning on the map after battle

@export var health_combat_start:int = 10
@export var enemy_id: String = "enemy_red_2"

func get_enemy_id() -> String:
	return enemy_id

func take_damage(damage_taken: int) -> void:
	health_combat_start -= damage_taken
	if health_combat_start <= 0:
		start_combat()

func start_combat() -> void:
	WorldMapState.defeat_enemy(enemy_id)
	queue_free()
	get_tree().change_scene_to_file("res://combat_scene.tscn")
