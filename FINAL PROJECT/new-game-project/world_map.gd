extends Node2D

func _ready() -> void:
	print(" World Map _ready() called")
	remove_defeated_enemies()

# Function works with enemy ids saved globally to not respawn defeated foes after combat

func remove_defeated_enemies() -> void:
	var enemy_nodes = $Enemies.get_children()
	print("Found ", enemy_nodes.size(), " enemies in group")
	
	for enemy in enemy_nodes:
		var e_id= ""
		
		if enemy.has_method("get_enemy_id"): 
			e_id = enemy.get_enemy_id()
		elif "enemy_id" in enemy:
			e_id = enemy.enemy_id
		print("Checking enemy with ID: ",e_id)
			
		if not e_id.is_empty() and WorldMapState.enemy_defeated(e_id):
			print("Removing defeated enemy: ", e_id)
			enemy.queue_free()
		else:
			print("Enemy stays alive: ",e_id)
