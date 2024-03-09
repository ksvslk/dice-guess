extends Control

# Flashing parameters
var start_color : Color = Color(1, 1, 1, 1) # White, fully opaque
var duration : float = 1.0 # Duration of one cycle (seconds)
var elapsed : float = 0.0 # Time elapsed since last cycle start
export var stopped = false
var end_color : Color = Color.greenyellow


func _ready():
	if not stopped:
		# Initialize the modulate property
		modulate = start_color

func _process(delta: float) -> void:
	if not stopped:
		elapsed += delta
		var t : float = elapsed / duration
		var sin_t : float = sin(t * 5 * PI) * 0.5 + 0.5 # Create a sine wave pattern
		modulate = start_color.linear_interpolate(end_color, sin_t)
		if elapsed >= duration:
			elapsed = 0.0 # Reset elapsed time after each cycle


func stop_animating():
	stopped = true
	
func start_animating():
	stopped = false
	
