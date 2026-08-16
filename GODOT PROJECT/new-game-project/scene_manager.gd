extends Node

# Connects buttons presses to respective scenes or simply emits quit func to exit

@export var main_menu_packed: PackedScene
@export var game_scene_packed: PackedScene

func _ready() -> void:
	load_main_menu("game_start")

func load_main_menu(_origin: String) -> void:
	var main_menu: Control = main_menu_packed.instantiate()
	main_menu.new_game_pressed.connect(new_game)
	main_menu.controls_pressed.connect(controls)
	main_menu.exit_pressed.connect(exit_game)
	add_child(main_menu)
	
func new_game(origin: String) -> void:
	if origin == "main_menu":
		get_node("MainMenu").queue_free()
	var game_scene: Node2D = game_scene_packed.instantiate()
	add_child(game_scene)
	
func controls(_origin: String) -> void:
	pass

func exit_game(_origin: String) -> void:
	get_tree().quit()
