extends Control

# Logic to create a simple but responsive main menu, used in scene manager

signal new_game_pressed(origin: String)
signal controls_pressed(origin: String)
signal exit_pressed(origin: String)

func _on_new_game_pressed() -> void:
	new_game_pressed.emit("main menu")
	queue_free()

func _on_controls_pressed() -> void:
	controls_pressed.emit("main menu")

func _on_exit_pressed() -> void:
	exit_pressed.emit("main menu")
