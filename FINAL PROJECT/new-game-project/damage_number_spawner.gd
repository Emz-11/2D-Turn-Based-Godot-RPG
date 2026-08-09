extends Node2D

class_name DamageNumber

@export var label_settings: LabelSettings
@export var critical_hit_color: Color = Color.YELLOW
@export var heal_spell_color: Color = Color.GREEN
# Variables for duration of number before fading away and distance it will float during its lifetime 
@export var lifetime: float = 1.5
@export var float_up: float = 80.0

# Function we call to display the numbers of the button used 
func spawn_label(number: float, critical_hit: bool = false, heal_spell: bool = false, spawn_global_pos: Vector2 = Vector2.ZERO) -> void:
	# Function creates a new Label node dynamically and adds it as a child of this Node
	var new_label = Label.new()
	add_child(new_label)
	
	# Settings for the Label that gets created, no decimals and applying the font style to it 
	new_label.text = str(int(number))
	new_label.label_settings = label_settings.duplicate() if label_settings else LabelSettings.new()
	new_label.z_index = 1000
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Changes the text color depending on number property
	if critical_hit:
		new_label.label_settings.font_color = critical_hit_color
	elif heal_spell:
		new_label.label_settings.font_color = heal_spell_color
	
	# Sets starting position and adds a bit of randomness to it
	await new_label.resized
	new_label.global_position = spawn_global_pos + Vector2(randf_range(-10, 10), randf_range(-80, 60))
	
	var floating_tween = create_tween()
	floating_tween.set_parallel(true)
	
	# Animates on the Y position so the number floats upwards, 2 variables determine the range and duration
	floating_tween.tween_property(new_label, "position:y", new_label.position.y - float_up, lifetime)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Animates the fade out effect, number starts fading after half the lifetime duration
	floating_tween.tween_property(new_label, "modulate:a", 0.0, lifetime * 0.5)\
	.set_delay(lifetime * 0.5).set_trans(Tween.TRANS_LINEAR)
	
	# Extra animation for critical hits
	if critical_hit:
		new_label.scale = Vector2(1.9, 1.9)
		floating_tween.tween_property(new_label, "scale", Vector2(1.2, 1.0), 0.75)\
			.set_trans(Tween.TRANS_BOUNCE)
	
	# Waits for the animation to complete then cleanly deletes the Label
	await get_tree().create_timer(lifetime + 0.1).timeout
	new_label.queue_free()
