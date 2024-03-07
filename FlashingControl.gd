extends Control

# Flashing parameters
var start_color : Color = Color(1, 1, 1, 1) # White, fully opaque
var end_color : Color = Color.greenyellow
var duration : float = 1.0 # Duration of one cycle (seconds)
var elapsed : float = 0.0 # Time elapsed since last cycle start

func _ready():
	# Initialize the modulate property
	modulate = start_color

func _process(delta: float) -> void:
	elapsed += delta
	var t : float = elapsed / duration
	var sin_t : float = sin(t * 2.0 * PI) * 0.5 + 0.5 # Create a sine wave pattern
	modulate = start_color.linear_interpolate(end_color, sin_t)
	
	if elapsed >= duration:
		elapsed = 0.0 # Reset elapsed time after each cycle
