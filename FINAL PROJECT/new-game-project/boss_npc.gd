extends CharacterBody2D

@export var health_combat_start:int = 10
@export var enemy_id: String = "enemy_boss_id"
func get_enemy_id() -> String:
	return enemy_id

func take_damage(damage_taken: int) -> void:
	health_combat_start -= damage_taken
	if health_combat_start <= 0:
		start_combat()

func start_combat() -> void:
	WorldMapState.defeat_enemy(enemy_id)
	queue_free()
	get_tree().change_scene_to_file("res://final_boss_scene.tscn")
